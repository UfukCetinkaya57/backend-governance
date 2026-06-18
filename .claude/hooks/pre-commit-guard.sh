#!/bin/bash
# Pre-commit governance guard
# Claude Code PreToolUse hook: git commit oncesi governance dosyalarini kontrol eder
# exit 0 = izin ver, exit 2 = engelle

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Sadece git commit komutlarini yakala
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Staged dosyalari kontrol et
STAGED=$(git diff --cached --name-only 2>/dev/null)

if [ -z "$STAGED" ]; then
  exit 0
fi

# Governance dosya pattern'leri
GOVERNANCE_PATTERNS=(
  "^\.claude/"
  "^CLAUDE\.md$"
  "^backend-governance/"
  "^proje/"
)

# Hassas dosya pattern'leri
SENSITIVE_PATTERNS=(
  "\.env$"
  "\.env\."
  "credentials"
  "secret"
  "\.pem$"
  "\.key$"
)

BLOCKED=""
WARNED=""

# Governance dosyalarini kontrol et
for file in $STAGED; do
  for pattern in "${GOVERNANCE_PATTERNS[@]}"; do
    if echo "$file" | grep -qE "$pattern"; then
      BLOCKED="$BLOCKED\n  - $file (governance)"
      # Otomatik unstage et
      git reset HEAD -- "$file" 2>/dev/null
    fi
  done
done

# Hassas dosyalari kontrol et
for file in $STAGED; do
  for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$file" | grep -qiE "$pattern"; then
      WARNED="$WARNED\n  - $file (hassas)"
      git reset HEAD -- "$file" 2>/dev/null
    fi
  done
done

# Rapor
if [ -n "$BLOCKED" ] || [ -n "$WARNED" ]; then
  echo "=== GOVERNANCE GUARD ===" >&2
  if [ -n "$BLOCKED" ]; then
    echo "Unstaged (governance):" >&2
    echo -e "$BLOCKED" >&2
  fi
  if [ -n "$WARNED" ]; then
    echo "Unstaged (hassas dosya):" >&2
    echo -e "$WARNED" >&2
  fi
  echo "========================" >&2
fi

# Kalan staged dosya var mi kontrol et
REMAINING=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$REMAINING" ]; then
  echo "ENGELLENDI: Tum dosyalar governance/hassas — commit edilecek dosya kalmadi." >&2
  exit 2
fi

# Izin ver (kalan dosyalar commit edilebilir)
exit 0
