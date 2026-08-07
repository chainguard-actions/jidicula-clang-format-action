<!-- markdownlint-disable -->

# Hardening Report: jidicula--clang-format-action/v4.17.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **jidicula--clang-format-action/v4.17.0** was hardened automatically. 10 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings.

1. action.yml line 34: `"${{ github.action_path }}/check.sh" "${{ inputs.clang-format-version }}" "${{ inputs.check-path }}" "${{ inputs.fallback-style }}" "${{ inputs.exclude-regex }}" "${{ inputs.include-regex }}"` — inputs.* and github.* expressions directly in run: block.

2. action.yml line 40: `SHA="${{ github.event.pull_request.head.sha }}"` — github.* expression directly in run: block.

3. action.yml line 45: `run: echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` — github.* expression directly in run: block.

4. action.yml line 50: `DEEPLINK="${{ github.server_url }}/${{ github.repository }}/commit/${{ env.SHA }}"` — github.* and env.* expressions directly in run: block.

5. .github/workflows/clang-format-image.yml line 54: `VERSION="${{ matrix.version-pair.version }}"` — matrix.* expression directly in run: block.

6. .github/workflows/tests.yml line 46: `run: test/test.sh ${{ matrix.clang-format-version }}` — matrix.* expression directly in run: block, unquoted.

Locations:

- `action.yml:34`
- `action.yml:40`
- `action.yml:45`
- `action.yml:50`
- `.github/workflows/clang-format-image.yml:54`
- `.github/workflows/tests.yml:46`

### github-env-injection (severity: high)

Untrusted input values are written to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. action.yml lines 40-41: `SHA="${{ github.event.pull_request.head.sha }}"` is assigned from a github context value, then `echo "SHA=$SHA" >> $GITHUB_ENV` writes it to GITHUB_ENV without sanitization. An attacker-controlled PR head SHA containing newlines could inject arbitrary environment variables.

2. action.yml line 45: `echo "SHA=${{ github.sha }}" >> $GITHUB_ENV` writes a github context value directly to GITHUB_ENV without sanitization.

3. .github/workflows/clang-format-image.yml lines 54-56: `VERSION="${{ matrix.version-pair.version }}"` is assigned from a matrix value, then `echo "MAJOR_VERSION=$MAJOR_VERSION" >> "$GITHUB_ENV"` writes a derived value to GITHUB_ENV without sanitization.

Locations:

- `action.yml:40`
- `action.yml:45`
- `.github/workflows/clang-format-image.yml:54`

### unpinned-uses (severity: high)

Multiple uses: references are pinned to mutable tags or version strings rather than immutable 40-character commit SHAs. This exposes the workflow to supply-chain attacks if the referenced action is compromised or the tag is moved.

- .github/workflows/clang-format-image.yml: `actions/checkout@v6`, `docker/login-action@v4.0.0`, `docker/metadata-action@v6.0.0`, `docker/build-push-action@v7.0.0`, `actions/setup-go@v6`
- .github/workflows/release.yml: `actions/checkout@v6`, `softprops/action-gh-release@v2`
- .github/workflows/shell-lint.yml: `actions/checkout@v6`, `ludeeus/action-shellcheck@2.0.0`, `actions/setup-go@v6`
- .github/workflows/tests.yml: `actions/checkout@v6` (used twice)

Locations:

- `.github/workflows/clang-format-image.yml:52`
- `.github/workflows/clang-format-image.yml:59`
- `.github/workflows/clang-format-image.yml:65`
- `.github/workflows/clang-format-image.yml:74`
- `.github/workflows/clang-format-image.yml:84`
- `.github/workflows/release.yml:14`
- `.github/workflows/release.yml:17`
- `.github/workflows/shell-lint.yml:16`
- `.github/workflows/shell-lint.yml:18`
- `.github/workflows/shell-lint.yml:20`
- `.github/workflows/tests.yml:44`
- `.github/workflows/tests.yml:83`

### missing-permissions (severity: medium)

The following workflow files have no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, workflows inherit the default repository token permissions, which may be overly broad (e.g., write access to contents).

- .github/workflows/release.yml: No top-level or job-level permissions block.
- .github/workflows/shell-lint.yml: No top-level or job-level permissions block.
- .github/workflows/tests.yml: No top-level or job-level permissions block.
- .github/workflows/test-ubuntu-22.04.yml: No top-level or job-level permissions block.
- .github/workflows/test-ubuntu-24.04.yml: No top-level or job-level permissions block.

Locations:

- `.github/workflows/release.yml:1`
- `.github/workflows/shell-lint.yml:1`
- `.github/workflows/tests.yml:1`
- `.github/workflows/test-ubuntu-22.04.yml:1`
- `.github/workflows/test-ubuntu-24.04.yml:1`

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all findings across action.yml and .github/workflows/*.yml files:

1. script-injection/static-inline-injection: Moved all ${{ inputs.* }}, ${{ github.* }}, and ${{ matrix.* }} expressions from run: blocks into env: blocks in action.yml (steps 1-4) and .github/workflows/clang-format-image.yml (Parse version tags step) and .github/workflows/tests.yml (Build and test step).

2. github-env-injection: Added sanitization (printf '%s' "$VAR" | tr -d '\n\r') before writing to $GITHUB_ENV in action.yml (both SHA-saving steps) and clang-format-image.yml (Parse version tags step).

3. unpinned-uses: Pinned all 7 action references to full 40-char commit SHAs with tag comments: actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803, docker/login-action@b45d80f862d83dbcd57f89517bcf500b2ab88fb2, docker/metadata-action@030e881283bb7a6894de51c315a6bfe6a94e05cf, docker/build-push-action@d08e5c354a6adb9ed34480a06d141179aa583294, actions/setup-go@924ae3a1cded613372ab5595356fb5720e22ba16, softprops/action-gh-release@3bb12739c298aeb8a4eeaf626c5b8d85266b0e65, ludeeus/action-shellcheck@00cae500b08a931fb5698e11e79bfbd38e612a38.

4. missing-permissions: Added permissions blocks to release.yml (contents: write), shell-lint.yml (contents: read), tests.yml (contents: read), test-ubuntu-22.04.yml (contents: read), test-ubuntu-24.04.yml (contents: read).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in `.github/workflows/clang-format-image.yml` line 104: moved `${{ secrets.GHCR_DELETE_TOKEN }}` out of the `run:` shell command and into an `env:` block as `GHCR_DELETE_TOKEN`, then referenced it as `"$GHCR_DELETE_TOKEN"` in the ghcr-cleaner command. This prevents shell metacharacters in the secret value from being interpreted by the shell.

