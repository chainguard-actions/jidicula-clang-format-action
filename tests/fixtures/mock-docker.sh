#!/bin/sh
# Mock docker script that simulates clang-format Docker container behavior.
# Handles: docker run --volume SRC:DST --workdir DIR IMAGE [clang-format-args...]
#
# This mock does NOT need real clang-format installed.
# It uses Python to check basic LLVM-style formatting rules.

# Parse docker arguments to extract clang-format args after the image name
found_image=0
skip_next=0
version_call=0
filepath=""
cf_args=""

for arg in "$@"; do
  if [ "$skip_next" = "1" ]; then
    skip_next=0
    continue
  fi
  case "$arg" in
    run)
      continue
      ;;
    --volume|-v|--workdir|-w|--env|-e)
      skip_next=1
      continue
      ;;
    ghcr.io/jidicula/clang-format:*)
      found_image=1
      continue
      ;;
    *)
      if [ "$found_image" = "1" ]; then
        cf_args="$cf_args $arg"
        case "$arg" in
          --version) version_call=1 ;;
        esac
      fi
      ;;
  esac
done

# Handle --version call
if [ "$version_call" = "1" ]; then
  echo "clang-format version 18.0.0"
  exit 0
fi

# Extract the filepath (last non-flag argument)
for arg in $cf_args; do
  case "$arg" in
    --*) continue ;;
    *) filepath="$arg" ;;
  esac
done

if [ -z "$filepath" ]; then
  # No file to check - just succeed
  exit 0
fi

# Use Python to check basic LLVM-style formatting rules
python3 - "$filepath" <<'PYEOF'
import sys
import re
import os

filepath = sys.argv[1]

if not os.path.isfile(filepath):
    print(f"mock-docker: file not found: {filepath}", file=sys.stderr)
    sys.exit(0)

try:
    with open(filepath, 'r') as f:
        content = f.read()
except Exception as e:
    print(f"mock-docker: cannot read {filepath}: {e}", file=sys.stderr)
    sys.exit(0)

issues = []
lines = content.split('\n')
for i, line in enumerate(lines, 1):
    # Check for opening brace without space before it (e.g., "main(){" or "foo(){")
    if re.search(r'\w\)\{', line):
        issues.append(f"line {i}: missing space before brace: {line.rstrip()}")
    # Check for 4-space indentation (LLVM style uses 2 spaces)
    if re.match(r'^    \S', line):
        issues.append(f"line {i}: 4-space indent detected (LLVM uses 2): {line.rstrip()}")

if issues:
    for issue in issues:
        print(issue, file=sys.stderr)
    sys.exit(1)

sys.exit(0)
PYEOF
