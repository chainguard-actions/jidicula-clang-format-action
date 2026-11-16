<!-- markdownlint-disable -->

# Hardening Report: jidicula--clang-format-action/v4.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **jidicula--clang-format-action/v4.18.0** was hardened automatically. 13 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the first composite step puts expressions straight into the run: script: "${{ github.action_path }}/check.sh" "${{ inputs.clang-format-version }}" "${{ inputs.check-path }}" "${{ inputs.fallback-style }}" "${{ inputs.exclude-regex }}" "${{ inputs.include-regex }}". A caller who controls an input can include a double quote or $(...) to break out of the quoting and run commands. Fix: move each value into an env: variable and expand it double-quoted.

Locations:

- `action.yml:34`

### script-injection (severity: high)

Rule (a): the 'Save PR head commit SHA' step puts an expression straight into the run: script: SHA="${{ github.event.pull_request.head.sha }}".

Locations:

- `action.yml:40`

### script-injection (severity: high)

Rule (a): the 'Save latest commit SHA if not PR' step puts an expression straight into the run: script: echo "SHA=${{ github.sha }}" >> $GITHUB_ENV.

Locations:

- `action.yml:45`

### script-injection (severity: high)

Rule (a): the 'Report failure in job summary' step puts expressions straight into the run: script: DEEPLINK="${{ github.server_url }}/${{ github.repository }}/commit/${{ env.SHA }}". env.SHA comes from the GITHUB_ENV writes in earlier steps.

Locations:

- `action.yml:50`

### github-env-injection (severity: high)

The 'Save PR head commit SHA' step takes a value from github.event.pull_request.head.sha and writes it to $GITHUB_ENV (echo "SHA=$SHA" >> $GITHUB_ENV) without first stripping newlines with printf '%s' ... | tr -d '\n\r'.

Locations:

- `action.yml:41`

### github-env-injection (severity: high)

The 'Save latest commit SHA if not PR' step writes ${{ github.sha }} to $GITHUB_ENV (echo "SHA=${{ github.sha }}" >> $GITHUB_ENV) without first stripping newlines with printf '%s' ... | tr -d '\n\r'.

Locations:

- `action.yml:45`

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

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 5bcadd4..7dcd2a9 100644
--- a/action.yml
+++ b/action.yml
@@ -1,10 +1,8 @@
 name: "clang-format Check"
 description: "Use clang-format to see if your C/C++/Protobuf code is formatted according to project guidelines."
-
 branding:
   icon: "check-circle"
   color: "blue"
-
 inputs:
   clang-format-version:
     description: 'The major version of clang-format that you want to use.'
@@ -26,27 +24,59 @@ inputs:
     description: 'A regex to override the C/C++/Protobuf/CUDA filetype regex. that should be checked. Default results in the regex defined in `check.sh`.'
     required: false
     default: ''
-
 runs:
   using: "composite"
   steps:
-    - run: |
-        "${{ github.action_path }}/check.sh" "${{ inputs.clang-format-version }}" "${{ inputs.check-path }}" "${{ inputs.fallback-style }}" "${{ inputs.exclude-regex }}" "${{ inputs.include-regex }}"
+    - env:
+        ACTION_PATH: ${{ github.action_path }}
+        CLANG_FORMAT_VERSION: ${{ inputs.clang-format-version }}
+        CHECK_PATH: ${{ inputs.check-path }}
+        FALLBACK_STYLE: ${{ inputs.fallback-style }}
+        EXCLUDE_REGEX: ${{ inputs.exclude-regex }}
+        INCLUDE_REGEX: ${{ inputs.include-regex }}
+      run: |
+        "$ACTION_PATH/check.sh" "$CLANG_FORMAT_VERSION" "$CHECK_PATH" "$FALLBACK_STYLE" ${EXCLUDE_REGEX:+"$EXCLUDE_REGEX"} ${INCLUDE_REGEX:+"$INCLUDE_REGEX"}
       shell: bash
     - name: Save PR head commit SHA
       if: failure() && github.event_name == 'pull_request'
       shell: bash
+      env:
+        PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
       run: |
-        SHA="${{ github.event.pull_request.head.sha }}"
-        echo "SHA=$SHA" >> $GITHUB_ENV
+        safe_sha=$(printf '%s' "$PR_HEAD_SHA" | tr -d '\n\r')
+        echo "SHA=$safe_sha" >> "$GITHUB_ENV"
     - name: Save latest commit SHA if not PR
       if: failure() && github.event_name != 'pull_request'
       shell: bash
-      run: echo "SHA=${{ github.sha }}" >> $GITHUB_ENV
-
+      env:
+        GITHUB_SHA_VALUE: ${{ github.sha }}
+      run: |
+        safe_sha=$(printf '%s' "$GITHUB_SHA_VALUE" | tr -d '\n\r')
+        echo "SHA=$safe_sha" >> "$GITHUB_ENV"
     - name: Report failure in job summary
       if: failure()
+      env:
+        SERVER_URL: ${{ github.server_url }}
+        REPOSITORY: ${{ github.repository }}
+        COMMIT_SHA: ${{ env.SHA }}
       run: |
-        DEEPLINK="${{ github.server_url }}/${{ github.repository }}/commit/${{ env.SHA }}"
-        echo -e "Format check failed on commit [${GITHUB_SHA:0:8}]($DEEPLINK) with files:\n$(<$GITHUB_WORKSPACE/failing-files.txt)" >> $GITHUB_STEP_SUMMARY
+        DEEPLINK="$SERVER_URL/$REPOSITORY/commit/$COMMIT_SHA"
+        echo -e "Format check failed on commit [${GITHUB_SHA:0:8}]($DEEPLINK) with files:\n$(< $GITHUB_WORKSPACE/failing-files.txt)" >> $GITHUB_STEP_SUMMARY
       shell: bash

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection, prior-fix

**Notes:**

action.yml: all ${{ }} expressions moved out of the run: scripts into env: blocks. ACTION_PATH and the five inputs are now env vars and passed to check.sh double-quoted. The PR head SHA and github.sha now have newlines stripped (printf | tr -d '\n\r') before they are written to $GITHUB_ENV. The summary step reads server_url, repository and env.SHA from env vars. This re-applies the previous harden with one change: exclude-regex and include-regex are passed as plain "$VAR" instead of ${VAR:+"$VAR"}. check.sh reads them by position ($4 and $5), so dropping an empty exclude-regex would have moved include-regex into $4 and used it as the exclude pattern. Passing both always matches upstream's five arguments.

