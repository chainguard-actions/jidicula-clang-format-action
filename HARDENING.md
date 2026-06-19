<!-- markdownlint-disable -->

# Hardening Report: jidicula--clang-format-action/v4.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **jidicula--clang-format-action/v4.18.0** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple GitHub Actions expressions (${{ ... }}) are directly interpolated inside run: shell command strings in action.yml, violating rule (a). 

1. Line 34: `"${{ github.action_path }}/check.sh" "${{ inputs.clang-format-version }}" "${{ inputs.check-path }}" "${{ inputs.fallback-style }}" "${{ inputs.exclude-regex }}" "${{ inputs.include-regex }}"` — Five `inputs.*` values and `github.action_path` are interpolated directly into the shell command. Attacker-controlled inputs (e.g. `inputs.exclude-regex`, `inputs.include-regex`) can inject arbitrary shell commands.

2. Line 39: `SHA="${{ github.event.pull_request.head.sha }}"` — `github.event.pull_request.head.sha` is interpolated directly into the shell.

3. Line 44: `run: echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` — `github.sha` is interpolated directly into the shell.

4. Line 49: `DEEPLINK="${{ github.server_url }}/${{ github.repository }}/commit/${{ env.SHA }}"` — `github.server_url`, `github.repository`, and `env.SHA` are interpolated directly into the shell.

Locations:

- `action.yml:34`
- `action.yml:39`
- `action.yml:44`
- `action.yml:49`

### github-env-injection (severity: high)

Untrusted GitHub context values are written to $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step).

1. Lines 39-40: `SHA="${{ github.event.pull_request.head.sha }}"` is captured and then `echo "SHA=$SHA" >> $GITHUB_ENV` writes it to GITHUB_ENV. The value from `github.event.pull_request.head.sha` is attacker-controlled (PR head SHA can be crafted) and is written without sanitization, enabling newline injection into the environment file.

2. Line 44: `echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` writes `github.sha` directly to GITHUB_ENV without sanitization.

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

Rewrote action.yml to move all ${{ }} expressions out of run: blocks and into env: blocks. Specifically: (1) Step 1 (check.sh invocation): moved github.action_path and all five inputs.* values to env: block; optional regex inputs use ${VAR:+"$VAR"} to avoid empty argument passing. (2) Step 'Save PR head commit SHA': moved github.event.pull_request.head.sha to env: block as PR_HEAD_SHA and sanitized with printf/tr before writing to $GITHUB_ENV. (3) Step 'Save latest commit SHA if not PR': moved github.sha to env: block as GITHUB_SHA_VALUE and sanitized with printf/tr before writing to $GITHUB_ENV. (4) Step 'Report failure in job summary': moved github.server_url, github.repository, and env.SHA to env: block as SERVER_URL, REPOSITORY, COMMIT_SHA respectively.

