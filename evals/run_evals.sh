#!/usr/bin/env bash
# Eval runner for anki-card-maker skill
# Usage: ./run_evals.sh [test-id]
#   Run all tests:    ./run_evals.sh
#   Run one test:     ./run_evals.sh test-01

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_CSV="$SCRIPT_DIR/prompts.csv"
RUBRIC="$SCRIPT_DIR/rubric.json"

# Auto-version: find next run number
RUN_NUM=1
while [ -d "$SCRIPT_DIR/artifacts-r${RUN_NUM}" ] || [ -d "$SCRIPT_DIR/run-${RUN_NUM}" ]; do
    RUN_NUM=$((RUN_NUM + 1))
done
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts-r${RUN_NUM}"
export EVAL_RUN_NUM="$RUN_NUM"
export EVAL_ARTIFACTS_DIR="$ARTIFACTS_DIR"

mkdir -p "$ARTIFACTS_DIR"
echo "=== Run $RUN_NUM ==="

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass_count=0
fail_count=0
skip_count=0
total=0

run_test() {
    local id="$1"
    local should_trigger="$2"
    local check_type="$3"
    local prompt="$4"
    local output_file="$ARTIFACTS_DIR/${id}.txt"

    total=$((total + 1))
    echo -n "[$id] ($check_type) ... "

    # Run claude -p and capture output
    if ! output=$(claude -p "$prompt" 2>/dev/null); then
        echo -e "${RED}ERROR${NC} (claude -p failed)"
        fail_count=$((fail_count + 1))
        return
    fi

    echo "$output" > "$output_file"

    # Deterministic checks
    local triggered=false
    local has_table=false
    local has_cards=false
    local no_yesno=true
    local atomic=true

    # Check if skill triggered: look for numbered card rows like "| 1 | basic |" or "| 2 | cloze |"
    # Requires a number followed by a card type in adjacent table cells
    if echo "$output" | grep -qE '\| *[0-9]+ *\| *(basic|cloze|reversed|\*\*basic\*\*|\*\*cloze\*\*|\*\*reversed\*\*) *\|'; then
        triggered=true
        has_table=true
        has_cards=true
    fi

    # Check for yes/no violations
    if echo "$output" | grep -qiE '(→ *(Yes|No|True|False) *$|→ *(Yes|No|True|False) *\|)'; then
        no_yesno=false
    fi

    # Evaluate result
    local test_passed=true
    local reason=""

    if [ "$should_trigger" = "true" ]; then
        if [ "$triggered" = "false" ]; then
            test_passed=false
            reason="Expected skill to trigger but it didn't"
        elif [ "$has_table" = "false" ]; then
            test_passed=false
            reason="Skill triggered but no card table found"
        fi
        if [ "$no_yesno" = "false" ]; then
            test_passed=false
            reason="$reason; Contains yes/no answer cards"
        fi
    else
        if [ "$triggered" = "true" ] && [ "$has_table" = "true" ]; then
            test_passed=false
            reason="Expected skill NOT to trigger but it generated cards"
        fi
    fi

    if [ "$test_passed" = "true" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} — $reason"
        fail_count=$((fail_count + 1))
    fi
}

# Parse CSV and run tests
filter_id="${1:-}"
first=true

while IFS=, read -r id should_trigger check_type prompt; do
    # Skip header
    if [ "$first" = "true" ]; then
        first=false
        continue
    fi

    # Remove surrounding quotes from prompt
    prompt="${prompt%\"}"
    prompt="${prompt#\"}"

    # Filter to single test if specified
    if [ -n "$filter_id" ] && [ "$id" != "$filter_id" ]; then
        continue
    fi

    run_test "$id" "$should_trigger" "$check_type" "$prompt"
done < "$PROMPTS_CSV"

echo ""
echo "================================"
echo -e "Results: ${GREEN}$pass_count passed${NC}, ${RED}$fail_count failed${NC} / $total total"
echo "Artifacts saved to: $ARTIFACTS_DIR/"
echo "================================"

exit $fail_count
