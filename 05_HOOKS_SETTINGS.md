# 05_HOOKS_SETTINGS — Otomasyon, Hook ve Settings Dosyaları
# backend-governance Project Knowledge Paketi
# Kapsam: .claude/hooks/ + .claude/settings.json + settings.local.json notu

═══════════════════════════════════════════════════════════
# BÖLÜM A: HOOK SCRİPTLERİ (.claude/hooks/)
# PreToolUse hook: her git commit öncesi otomatik çalışır
# Bağlantı: .claude/settings.json > PreToolUse > Bash matcher
═══════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════
=== FILE: .claude/hooks/pre-commit-guard.sh ===
Boyut: 1.9 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════

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

═══════════════════════════════════════════════════════════
# Hook Açıklaması
# Nasıl bağlanıyor: settings.json > hooks > PreToolUse > matcher: "Bash"
# Çalışma mantığı:
#   1. Her Bash tool call öncesi bu script çalışır
#   2. Komut "git commit" içeriyorsa devreye girer
#   3. Staged dosyaları tarar:
#      - .claude/, CLAUDE.md, backend-governance/, proje/ → otomatik unstage
#      - .env, credentials, *.pem, *.key → otomatik unstage + uyarı
#   4. Tüm dosyalar dışlandıysa exit 2 (commit engellendi)
#   5. Kalan dosya varsa exit 0 (commit devam eder)
# /commit skill'i ile paralel çalışır: skill kullanıcıya anlatır, hook teknik garantidir
═══════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════
# BÖLÜM B: SETTINGS DOSYALARI
═══════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════
=== FILE: .claude/settings.json ===
Boyut: 0.2 KB | Son değişiklik: 2026-03-21
İçerik: Repo'ya commit'lenir. Sadece hook kaydını içerir.
═══════════════════════════════════════════════════════════

{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-commit-guard.sh"
          }
        ]
      }
    ]
  }
}

═══════════════════════════════════════════════════════════
=== FILE: .claude/settings.local.json ===
Boyut: 0.2 KB | Durum: UNTRACKED (git'e commit'lenmemiş)
[MAKİNE-SPESİFİK — içerik atlandı]
İçinde mutlak path vardır: c:\Users\ufukc\OneDrive\Desktop\...
Bu dosya template'in parçası değil — her kullanıcı kendi makinesinde ayrı oluşturur.
İçerik: Sadece Bash izin whitelist'i (dotnet build, git rm, git log gibi komutlar).
Format: {"permissions": {"allow": ["Bash(komut:*)"]}}
═══════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════
# BÖLÜM C: DİĞER .claude/ KÖK DOSYALARI
# .claude/ altında yukarıdakiler dışında dosya yok.
# agent-memory/ klasörü var ama içi boş (02_AGENTS.md'de detay).
═══════════════════════════════════════════════════════════

Diğer .claude/ dosyaları: [YOK]

═══════════════════════════════════════════════════════════
# Frontend-Governance İçin Notlar
#
# settings.json'u kopyalarken:
#   - Hook path'ini güncelle: "bash .claude/hooks/pre-commit-guard.sh"
#   - Pre-commit-guard.sh'daki GOVERNANCE_PATTERNS frontend'e göre uyarla
#   - Matcher: "Bash" tüm bash çağrılarını yakalar (bu kasıtlı)
#
# settings.local.json:
#   - Her geliştirici kendi izin listesini oluşturur
#   - Template'e dahil edilmez — .gitignore'a alınmalı
#   - Mutlak path içerebileceği için paylaşılmaz
═══════════════════════════════════════════════════════════
