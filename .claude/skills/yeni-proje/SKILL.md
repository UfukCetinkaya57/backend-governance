---
name: yeni-proje
description: Governance yapisina yeni proje ekler
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
argument-hint: [proje-adi]
---

# Yeni Proje Ekleme

`$ARGUMENTS` adinda yeni bir proje olustur ve governance yapisina bagla.

## Onkosullar
- `backend-governance/` klasoru mevcut olmali (main2/ altinda)
- Proje adi verilmis olmali ($ARGUMENTS)

## Adimlar

### 1. Proje Klasoru Olustur
```bash
mkdir -p /c/Users/ufukc/OneDrive/Desktop/main2/$ARGUMENTS
cd /c/Users/ufukc/OneDrive/Desktop/main2/$ARGUMENTS
```

### 2. CLAUDE.md Kopyala
Kaynak: `../memory-box/CLAUDE.md` (referans proje)
Hedef: `./$ARGUMENTS/CLAUDE.md`

Kopyaladiktan sonra Deployment bolumundeki proje adini ve path'leri `$ARGUMENTS`'a uyarla.

### 3. Agent Dosyalarini Kopyala
```bash
mkdir -p .claude/agents/
cp ../backend-governance/.claude/agents/*.md .claude/agents/
```
Not: Agent dosyalari KOPYA — symlink degil.

### 4. Rules Symlink Olustur
```bash
mkdir -p .claude/rules/
# Windows junction
cmd //c "mklink /J .claude\rules\governance ..\..\backend-governance\.claude\rules"
```

### 5. Skills Symlink Olustur
```bash
# Windows junction — skills merkezi, tum projeler ayni skill'leri kullanir
cmd //c "mklink /J .claude\skills ..\backend-governance\.claude\skills"
```

### 6. Hooks Symlink Olustur
```bash
# Windows junction — hooks merkezi
cmd //c "mklink /J .claude\hooks ..\backend-governance\.claude\hooks"
```

### 7. Settings.json Kopyala (Hook Config)
```bash
cp ../backend-governance/.claude/settings.json .claude/settings.json
```
Not: settings.json KOPYA — symlink degil (proje bazli override gerekebilir).

### 8. backend-governance Symlink
```bash
# Windows junction
cmd //c "mklink /J backend-governance ..\backend-governance"
```
**ONEMLI:** Clone veya kopya YASAK. Her zaman symlink/junction.

### 9. Proje Profili Olustur
```bash
mkdir -p proje/
cp ../backend-governance/proje/SABLON.md proje/$ARGUMENTS.md
```

### 10. proje/CLAUDE.md Olustur
Icerik:
```markdown
# Aktif Proje

@proje/$ARGUMENTS.md
```

### 11. Proje Kesfi Baslat
Proje klasorunde kod varsa (git repo, package.json, *.csproj vb.):
- `backend-governance/surec/proje-kesfi.md` dosyasini oku
- Otomatik proje kesfini calistir
- `proje/$ARGUMENTS.md` dosyasini doldur

Kod yoksa (bos proje):
- Kullaniciya sor: stack ne olacak?
- SABLON.md'yi minimal doldur

### 12. Dogrulama
- [ ] CLAUDE.md mevcut ve proje adina uyarlanmis
- [ ] .claude/agents/ dosyalari kopyalanmis
- [ ] .claude/rules/governance/ symlink calisiyor
- [ ] .claude/skills/ symlink calisiyor
- [ ] .claude/hooks/ symlink calisiyor
- [ ] .claude/settings.json mevcut (hook config)
- [ ] backend-governance/ symlink calisiyor
- [ ] proje/CLAUDE.md aktif proje isaretli
- [ ] proje/$ARGUMENTS.md olusmus

### 13. Raporla
- Olusturulan klasor yapisi
- Symlink'ler dogru mu
- Siradaki adim: proje kesfini tamamla veya kod yazmaya basla
