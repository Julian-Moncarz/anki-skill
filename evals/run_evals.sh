#!/usr/bin/env bash
# Eval runner for anki-card-maker skill
# Usage: ./run_evals.sh [test-id]
#   Run all tests:    ./run_evals.sh
#   Run one test:     ./run_evals.sh test-01

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_CSV="$SCRIPT_DIR/prompts.csv"

# Auto-version: find highest existing run number and increment
RUN_NUM=$(ls -d "$SCRIPT_DIR"/artifacts-r* "$SCRIPT_DIR"/grades-r* 2>/dev/null | sed 's/.*-r//' | sort -n | tail -1)
RUN_NUM=$(( ${RUN_NUM:-0} + 1 ))
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts-r${RUN_NUM}"
export EVAL_RUN_NUM="$RUN_NUM"
export EVAL_ARTIFACTS_DIR="$ARTIFACTS_DIR"

mkdir -p "$ARTIFACTS_DIR"
echo "=== Run $RUN_NUM ==="

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

filter_id="${1:-}"

# Collect tests to run
declare -a test_ids=()
declare -a test_triggers=()
declare -a test_types=()
declare -a test_prompts=()

first=true
while IFS=, read -r id should_trigger check_type prompt; do
    if [ "$first" = "true" ]; then
        first=false
        continue
    fi
    prompt="${prompt%\"}"
    prompt="${prompt#\"}"
    if [ -n "$filter_id" ] && [ "$id" != "$filter_id" ]; then
        continue
    fi
    test_ids+=("$id")
    test_triggers+=("$should_trigger")
    test_types+=("$check_type")
    test_prompts+=("$prompt")
done < "$PROMPTS_CSV"

# Run all tests in parallel
declare -a pids=()
for i in "${!test_ids[@]}"; do
    id="${test_ids[$i]}"
    prompt="${test_prompts[$i]}"
    output_file="$ARTIFACTS_DIR/${id}.txt"
    (
        claude -p "$prompt" > "$output_file" 2>/dev/null
    ) &
    pids+=($!)
    echo "[$id] launched..."
done

# Wait for all to finish
echo "Waiting for ${#pids[@]} tests to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
done
echo "All tests complete."

# Now check results
pass_count=0
fail_count=0
total=0

for i in "${!test_ids[@]}"; do
    id="${test_ids[$i]}"
    should_trigger="${test_triggers[$i]}"
    check_type="${test_types[$i]}"
    output_file="$ARTIFACTS_DIR/${id}.txt"

    total=$((total + 1))

    if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
        echo -e "[$id] ($check_type) ... ${RED}ERROR${NC} (no output)"
        fail_count=$((fail_count + 1))
        continue
    fi

    output=$(cat "$output_file")
    triggered=false
    no_yesno=true

    if echo "$output" | grep -qE '\| *[0-9]+ *\| *(basic|cloze|reversed|\*\*basic\*\*|\*\*cloze\*\*|\*\*reversed\*\*) *\|'; then
        triggered=true
    fi

    if echo "$output" | grep -qiE '(→ *(Yes|No|True|False) *$|→ *(Yes|No|True|False) *\|)'; then
        no_yesno=false
    fi

    test_passed=true
    reason=""

    if [ "$should_trigger" = "true" ]; then
        if [ "$triggered" = "false" ]; then
            test_passed=false
            reason="Expected skill to trigger but it didn't"
        fi
        if [ "$no_yesno" = "false" ]; then
            test_passed=false
            reason="$reason; Contains yes/no answer cards"
        fi
    else
        if [ "$triggered" = "true" ]; then
            test_passed=false
            reason="Expected skill NOT to trigger but it generated cards"
        fi
    fi

    if [ "$test_passed" = "true" ]; then
        echo -e "[$id] ($check_type) ... ${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "[$id] ($check_type) ... ${RED}FAIL${NC} — $reason"
        fail_count=$((fail_count + 1))
    fi
done

echo ""
echo "================================"
echo -e "Results: ${GREEN}$pass_count passed${NC}, ${RED}$fail_count failed${NC} / $total total"
echo "Artifacts saved to: $ARTIFACTS_DIR/"
echo "================================"

exit $fail_count
