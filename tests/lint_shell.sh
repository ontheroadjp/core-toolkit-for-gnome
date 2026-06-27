#!/bin/bash

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

if command -v shellcheck >/dev/null 2>&1; then
    CHECKER="shellcheck"
else
    CHECKER="bash_n"
fi

while IFS= read -r -d '' script; do
    rel="${script#"${REPO_DIR}/"}"
    if [ "$CHECKER" = "shellcheck" ]; then
        if shellcheck "$script" 2>/dev/null; then
            pass "shellcheck: ${rel}"
        else
            fail "shellcheck: ${rel}"
        fi
    else
        if bash -n "$script" 2>/dev/null; then
            pass "bash -n: ${rel}"
        else
            fail "bash -n: ${rel}"
        fi
    fi
done < <(find "${REPO_DIR}" -name "install.sh" -print0 | sort -z)

echo ""
echo "=============================="
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "=============================="
[ "$FAIL" -eq 0 ]
