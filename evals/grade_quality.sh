#!/usr/bin/env bash
# Rubric-based quality grading for anki-card-maker skill
# Uses the SKILL.md + card selection guide as the rubric.
#
# Usage: ./grade_quality.sh [test-id]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_MD="$SKILL_DIR/SKILL.md"
SELECTION_GUIDE="$SKILL_DIR/references/card-selection-guide.md"

# Use the run number from run_evals.sh if set, otherwise find the latest artifacts dir
if [ -n "${EVAL_RUN_NUM:-}" ]; then
    RUN_NUM="$EVAL_RUN_NUM"
else
    RUN_NUM=$(ls -d "$SCRIPT_DIR"/artifacts-r* 2>/dev/null | sed 's/.*artifacts-r//' | sort -n | tail -1)
    if [ -z "$RUN_NUM" ]; then
        echo "No artifacts found. Run run_evals.sh first."
        exit 1
    fi
fi

ARTIFACTS_DIR="$SCRIPT_DIR/artifacts-r${RUN_NUM}"
GRADES_DIR="$SCRIPT_DIR/grades-r${RUN_NUM}"

mkdir -p "$GRADES_DIR"
echo "=== Grading run $RUN_NUM ==="

SKILL_CONTENT=$(cat "$SKILL_MD")
SELECTION_CONTENT=$(cat "$SELECTION_GUIDE")

GRADER_PROMPT="You are a strict evaluator. You will be given:
1. A SKILL.md that defines rules for creating Anki flashcards
2. A card selection guide with community-sourced principles on WHAT deserves a card
3. The actual output from an agent that used this skill

IMPORTANT: The agent WAS given source content as part of its prompt. You cannot see the original prompt, so do NOT penalize for 'not showing source content' or 'using general knowledge' — assume content was provided and the cards are based on it.

Check the output against EVERY rule in the skill AND the card selection guide. Evaluate both:
- CARD QUALITY: formatting, atomicity, brevity, ambiguity, etc. (from SKILL.md)
- CARD SELECTION: are the right things being turned into cards? Are trivia/orphans/mirror-deducible cards present? Is the type distribution good (enough why/how cards, not all definitional)? (from both documents)

When SKILL.md and the card selection guide conflict, SKILL.md takes precedence.

Important calibration notes:
- When the agent merges mirror pairs into a single multi-cloze card (e.g., merging encrypt/decrypt into one card with two fills), this is the CORRECT fix for mirror-deducibility. Do NOT then penalize the cloze fills for being deducible from each other within the same card — the whole point of the merge is to test them together.
- Type distribution targets (~40% why/how) are flexible when the source content is thin or purely factual. If the source only contains definitions and no causal content, the agent cannot invent why/how cards without going beyond the source. Do not penalize for this.
- If the content only supports 1-2 cards, that is OK. Do not penalize for low card count when the agent correctly flags thin content to the user.

Respond with ONLY valid JSON (no markdown fences, no explanation outside the JSON):
{
  \"overall_pass\": boolean (true only if zero violations),
  \"score\": integer 0-100,
  \"violations\": [
    {\"rule\": \"which rule was violated\", \"card\": \"which card # or general\", \"detail\": \"what went wrong\"}
  ]
}

If there are no violations, return an empty violations array and score 100.

=== SKILL.md ===
$SKILL_CONTENT
=== END SKILL.md ===

=== CARD SELECTION GUIDE ===
$SELECTION_CONTENT
=== END CARD SELECTION GUIDE ===

=== AGENT OUTPUT TO EVALUATE ==="

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

filter_id="${1:-}"

# Collect artifacts to grade
declare -a grade_ids=()
declare -a grade_files=()

for artifact in "$ARTIFACTS_DIR"/test-*.txt; do
    test_id=$(basename "$artifact" .txt)

    if [ -n "$filter_id" ] && [ "$test_id" != "$filter_id" ]; then
        continue
    fi

    # Skip negative control tests
    if grep -q "^${test_id},false," "$SCRIPT_DIR/prompts.csv" 2>/dev/null; then
        echo "[$test_id] SKIP (negative control)"
        continue
    fi

    grade_ids+=("$test_id")
    grade_files+=("$artifact")
done

# Launch all grading in parallel
declare -a pids=()
for i in "${!grade_ids[@]}"; do
    test_id="${grade_ids[$i]}"
    artifact="${grade_files[$i]}"
    grade_file="$GRADES_DIR/${test_id}.json"
    cards_content=$(cat "$artifact")

    (
        grade=$(claude -p "${GRADER_PROMPT}
${cards_content}
=== END OUTPUT ===" 2>/dev/null || echo '{"overall_pass":false,"score":0,"violations":[{"rule":"grading error","card":"general","detail":"claude -p failed"}]}')

        # Extract JSON from response
        clean_grade=$(echo "$grade" | python3 -c "
import sys, re, json
text = sys.stdin.read().strip()
match = re.search(r'\{[\s\S]*\}', text)
if match:
    candidate = match.group(0)
    try:
        json.loads(candidate)
        print(candidate)
    except json.JSONDecodeError:
        for m in re.finditer(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', text):
            try:
                json.loads(m.group(0))
                candidate = m.group(0)
            except json.JSONDecodeError:
                pass
        print(candidate)
else:
    print(text)
" 2>/dev/null || echo "$grade")

        echo "$clean_grade" > "$grade_file"
    ) &
    pids+=($!)
    echo "[$test_id] grading launched..."
done

# Wait for all grading to finish
echo "Waiting for ${#pids[@]} grades to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
done
echo "All grading complete."
echo ""

# Now report results
pass_count=0
fail_count=0
total=0

for i in "${!grade_ids[@]}"; do
    test_id="${grade_ids[$i]}"
    grade_file="$GRADES_DIR/${test_id}.json"
    total=$((total + 1))

    if [ ! -f "$grade_file" ] || [ ! -s "$grade_file" ]; then
        echo -e "[$test_id] ${RED}ERROR${NC} (no grade file)"
        fail_count=$((fail_count + 1))
        continue
    fi

    result=$(python3 -c "
import json, sys
d = json.load(open('$grade_file'))
score = d['score']
passed = d['overall_pass']
violations = d.get('violations', [])
print(score)
print(passed)
for v in violations:
    print(f\"  - [{v.get('card','?')}] {v['rule']}: {v['detail']}\")
" 2>/dev/null || echo "?\n?\nPARSE ERROR")

    score=$(echo "$result" | head -1)
    passed=$(echo "$result" | sed -n '2p')

    if [ "$passed" = "True" ]; then
        echo -e "[$test_id] ${GREEN}PASS${NC} (score: $score/100)"
        pass_count=$((pass_count + 1))
    else
        echo -e "[$test_id] ${RED}FAIL${NC} (score: $score/100)"
        echo "$result" | tail -n +3
        fail_count=$((fail_count + 1))
    fi
done

echo ""
echo "================================"
echo -e "Results: ${GREEN}$pass_count passed${NC}, ${RED}$fail_count failed${NC} / $total total"
echo "Grades saved to: $GRADES_DIR/"
echo "================================"
