---
name: governance-kur
description: Yeni bir projeye backend-governance yapisini eksiksiz baglar (junction + @import). Proje reposuna GIRMEDEN governance'i tam calisir hale getirir. Yeni proje ilk kurulumunda kullanilir.
---

# Governance Kurulum Skill'i

Bu skill, backend-governance yapisini bir projeye **tek kaynaktan** baglar:
governance TEK yerde (backend-governance/) yasar, projeye junction + @import ile
baglanir. Kopya YOK, drift YOK, proje git reposuna GIRMEZ.

## Ne Zaman Kullanilir
- Yeni bir projeye ilk kez governance kurulurken
- Mevcut bir projede governance kopyalari drift ettiyse (temiz kaynaga baglamak icin)

## On Kosul
- `backend-governance/` klasoru projenin icinde OLMALI (klonla veya kopyala):
  `git clone <backend-governance-repo-url> backend-governance`
  (remote ornek: github.com/UfukCetinkaya57/backend-governance)
- Windows: junction admin GEREKTIRMEZ (symlink'in aksine). OneDrive'da junction
  CALISIR ama hardlink/symlink dosya CALISMAZ (bulut cakismasi) — bu yuzden
  CLAUDE.md icin @import kullanilir, link degil.

## Kurulum Adimlari (sirayla)

### 1. On kontrol
```bash
# backend-governance projede var mi
[ -d backend-governance/.claude ] && echo "OK" || echo "ONCE backend-governance klonla"
# .claude zaten junction mi (tekrar kurma)
cmd //c "dir /AL" | grep -i "claude \["
```

### 2. Mevcut .claude'u yedekle (varsa, gercek klasorse)
```bash
# .claude gercek klasorse yedekle, junction'sa atla
[ -d .claude ] && [ ! -L .claude ] && cp -r .claude .claude-backup
```

### 3. .claude junction kur (backend-governance/.claude'a)
```bash
# eski .claude'u kaldir, junction kur
cmd //c "rmdir /S /Q .claude" 2>/dev/null
cmd //c "mklink /J .claude backend-governance\.claude"
```

### 4. Kok CLAUDE.md = @import satiri
```bash
# kok CLAUDE.md varsa yedekle
[ -f CLAUDE.md ] && cp CLAUDE.md CLAUDE.md.backup
# tek satir @import (icerik backend-governance/CLAUDE.md'de)
echo "@backend-governance/CLAUDE.md" > CLAUDE.md
```
NOT: CLAUDE.md'ye BOM EKLEME (@import BOM'la bozulabilir). Duz UTF-8.

### 5. .gitignore'a governance ekle (repoya girmesin)
```bash
grep -q "^backend-governance/" .gitignore 2>/dev/null || cat >> .gitignore <<'EOF'

# Governance (tek kaynak backend-governance/, repoya girmez)
backend-governance/
.claude/agents/
.claude/rules/
.claude/skills/
.claude/hooks/
.claude/agent-memory/
.claude/settings.local.json
EOF
```
NOT: kok CLAUDE.md (@import satiri) repoya GIREBILIR — sadece "backend-governance
oku" satiri, gercek kurallar backend-governance'da (o ignore'lu). Istersen
`CLAUDE.md` da ignore'a eklenebilir.

### 6. DOGRULAMA (kurulum sonrasi)
```bash
# junction hedefi dogru mu
cmd //c "dir /AL" | grep -i "claude \[.*backend-governance"
# @import satiri var mi
cat CLAUDE.md   # "@backend-governance/CLAUDE.md" olmali
# stack/surec/proje erisilebilir mi (CLAUDE.md bunlara atif yapar)
ls backend-governance/stack/ backend-governance/surec/ backend-governance/proje/
```

### 7. KESIN TEST (kullaniciya birak — sadece yeni oturum gorur)
Bu skill'i calistiran oturum kurallari zaten yukleyemez (@import/junction yeni
oturumda etkinlesir). Kullaniciya soyle:
> "Yeni bir Claude Code oturumu ac, 'governance kurallari yuklu mu, esikli mod
> ilani var mi' diye sor. Varsa kurulum basarili."

## Nihai Yapi
```
proje/
├── CLAUDE.md          → @backend-governance/CLAUDE.md   (@import, link degil)
├── .claude/           → junction → backend-governance/.claude/
└── backend-governance/    ← TEK KAYNAK (CLAUDE.md, .claude/rules+agents+skills, stack, surec, proje)
```

## Kalan Riskler / Notlar
- **OneDrive:** junction (klasor) calisir; hardlink/symlink (dosya) CALISMAZ.
  CLAUDE.md icin DAIMA @import kullan, link deneme.
- **Proje-ozel profil:** her proje kendi `backend-governance/proje/<proje>.md`
  profilini tutar (mentorbridge.md gibi) — ortak kurallar paylasilir, profil ayri.
- **Guncelleme:** governance degisikligi backend-governance/'a yazilir, tum bagli
  projelerde ANINDA gecerli (tek kaynak). Ayrica commit+push ile GitHub yedek.
- **Junction tespit edildi calisir kaniti:** menti-mentor'da test edildi
  (2026-07-01) — junction + @import ikisi de yeni oturumda governance'i yukledi.
