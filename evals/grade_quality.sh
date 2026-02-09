#!/usr/bin/env bash
# Rubric-based quality grading for anki-card-maker skill
# Uses the SKILL.md itself as the rubric — checks output against every rule in the skill.
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
    # Find the highest numbered artifacts-rN directory
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

Check the output against EVERY rule in the skill AND the card selection guide. Evaluate both:
- CARD QUALITY: formatting, atomicity, brevity, ambiguity, etc. (from SKILL.md)
- CARD SELECTION: are the right things being turned into cards? Are trivia/orphans/mirror-deducible cards present? Is the type distribution good (enough why/how cards, not all definitional)? (from both documents)

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
pass_count=0
fail_count=0
total=0

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

    total=$((total + 1))
    echo -n "[$test_id] Grading... "

    cards_content=$(cat "$artifact")
    grade_file="$GRADES_DIR/${test_id}.json"

    if grade=$(claude -p "${GRADER_PROMPT}
${cards_content}
=== END OUTPUT ===" 2>/dev/null); then
        # Extract JSON from response (handles markdown fences, preamble text, etc.)
        clean_grade=$(echo "$grade" | python3 -c "
import sys, re, json
text = sys.stdin.read().strip()
# Try to find JSON object in the text
match = re.search(r'\{[\s\S]*\}', text)
if match:
    candidate = match.group(0)
    try:
        json.loads(candidate)
        print(candidate)
    except json.JSONDecodeError:
        # Try to find the last complete JSON object
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
            echo -e "${GREEN}PASS${NC} (score: $score/100)"
            pass_count=$((pass_count + 1))
        else
            echo -e "${RED}FAIL${NC} (score: $score/100)"
            echo "$result" | tail -n +3
            fail_count=$((fail_count + 1))
        fi
    else
        echo -e "${RED}ERROR${NC} (grading failed)"
        fail_count=$((fail_count + 1))
    fi
done

echo ""
echo "================================"
echo -e "Results: ${GREEN}$pass_count passed${NC}, ${RED}$fail_count failed${NC} / $total total"
echo "Grades saved to: $GRADES_DIR/"
echo "================================"
