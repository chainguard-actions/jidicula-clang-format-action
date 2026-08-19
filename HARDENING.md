<!-- markdownlint-disable -->

# Hardening Report: jidicula--clang-format-action/v4.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **jidicula--clang-format-action/v4.18.0** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml, violating rule (a). This allows template substitution to inject arbitrary shell metacharacters before the shell ever sees the string.

1. Line 33 (step 1): `"${{ github.action_path }}/check.sh" "${{ inputs.clang-format-version }}" "${{ inputs.check-path }}" "${{ inputs.fallback-style }}" "${{ inputs.exclude-regex }}" "${{ inputs.include-regex }}"` — all five inputs and github.action_path are interpolated directly.

2. Line 39 (step 2): `SHA="${{ github.event.pull_request.head.sha }}"` — attacker-controlled PR head SHA interpolated directly.

3. Line 44 (step 3): `echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` — github.sha interpolated directly.

4. Line 48 (step 4): `DEEPLINK="${{ github.server_url }}/${{ github.repository }}/commit/${{ env.SHA }}"` — multiple github context values interpolated directly.

Locations:

- `action.yml:33`
- `action.yml:39`
- `action.yml:44`
- `action.yml:48`

### github-env-injection (severity: high)

Untrusted input values are written to $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`), enabling environment variable injection attacks.

1. Line 39–40 (step 2): `SHA="${{ github.event.pull_request.head.sha }}"` is assigned from an attacker-controlled PR head SHA, then `echo "SHA=$SHA" >> $GITHUB_ENV` writes it unsanitized. A newline in the SHA value could inject additional environment variables.

2. Line 44 (step 3): `echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` writes github.sha directly to GITHUB_ENV without sanitization.

Locations:

- `action.yml:39`
- `action.yml:44`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.clang-format-version }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:34`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.check-path }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:34`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fallback-style }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:34`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.exclude-regex }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:34`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.include-regex }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:34`

### static-inline-injection (severity: high)

shell injection: expression "${{ github.event.pull_request.head.sha }}" appears directly in run: block of step "Save PR head commit SHA"; move to env: map

Locations:

- `action.yml:40`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all findings in action.yml:
1. Step 1 (check.sh): Moved github.action_path and all 5 inputs (clang-format-version, check-path, fallback-style, exclude-regex, include-regex) to env: block. Used ${VAR:+"$VAR"} for optional empty-default inputs (exclude-regex, include-regex) to avoid passing empty positional arguments.
2. Step 2 (Save PR head commit SHA): Moved github.event.pull_request.head.sha to env: PR_HEAD_SHA, then sanitized with printf + tr -d '\n\r' before writing to $GITHUB_ENV.
3. Step 3 (Save latest commit SHA): Moved github.sha to env: GITHUB_SHA_VALUE, then sanitized with printf + tr -d '\n\r' before writing to $GITHUB_ENV.
4. Step 4 (Report failure): Moved github.server_url, github.repository, and env.SHA to env: block as SERVER_URL, REPOSITORY, and COMMIT_SHA respectively.

