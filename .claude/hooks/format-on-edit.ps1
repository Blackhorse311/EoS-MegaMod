# PostToolUse hook: format the file Claude just edited, when a formatter is available.
# Receives the tool payload as JSON on stdin. Must never block or fail the edit — always exit 0.
#
# Deliberately skipped: .cs files. `dotnet format` needs project context and takes seconds
# per run, which is too slow per-edit. Rely on IDE/CI formatting for C#, or add a
# project-local branch here if a fast formatter (e.g. csharpier) is installed.

$ErrorActionPreference = 'SilentlyContinue'

try {
    $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $file = $payload.tool_input.file_path
    if (-not $file -or -not (Test-Path -LiteralPath $file)) { exit 0 }

    $ext = [IO.Path]::GetExtension($file).ToLowerInvariant()

    switch -Regex ($ext) {
        '^\.py$' {
            if (Get-Command ruff -ErrorAction SilentlyContinue) {
                & ruff format --quiet -- $file 2>$null | Out-Null
            }
            elseif (Get-Command black -ErrorAction SilentlyContinue) {
                & black --quiet -- $file 2>$null | Out-Null
            }
        }
        '^\.(ts|tsx|js|jsx|json|css|scss|html|md|yaml|yml)$' {
            # Only projects that actually use Node get prettier; --no-install avoids
            # a slow network fetch in projects that don't have it.
            if (Test-Path 'package.json') {
                & npx --no-install prettier --write -- $file 2>$null | Out-Null
            }
        }
    }
}
catch { }

exit 0
