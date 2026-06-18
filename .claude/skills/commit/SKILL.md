---
name: commit
description: Governance kurallarına uygun commit yapar
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [commit mesaji (opsiyonel)]
---

# Governance Commit

Governance kurallarına uygun commit olustur. Kurallar:

## Adimlar

### 1. Degisiklikleri Kontrol Et
```
git status
git diff --cached --name-only  (staged dosyalar)
git diff --name-only           (unstaged dosyalar)
```

### 2. Governance Dosyalarini HARIC TUT
Asagidaki dosyalar/klasorler commit'e DAHIL EDILMEZ — staged ise unstage et:
- `.claude/` (agents, rules, skills, settings)
- `CLAUDE.md` (kok dizindeki)
- `backend-governance/` (klasor veya symlink)
- `proje/` (proje profilleri)

```bash
git reset HEAD -- .claude/ CLAUDE.md backend-governance/ proje/ 2>/dev/null
```

### 3. Hassas Dosyalari ENGELLE
Asagidaki dosyalar commit'e ALINMAZ. Staged ise unstage et ve UYAR:
- `.env`, `.env.*`
- `*credentials*`, `*secret*`
- `*.pem`, `*.key`

### 4. Dosya Encoding Kontrolu
Tum dosyalar **UTF-8 BOM** formatinda commit edilmeli.
Commit oncesi degisen dosyalari kontrol et:
```bash
# BOM kontrolu: dosyanin ilk 3 byte'i EF BB BF olmali
file --mime-encoding <dosya>
```
Eger BOM eksikse, dosyanin basina BOM ekle:
```bash
# Python ile BOM ekleme
python3 -c "
import sys
for f in sys.argv[1:]:
    with open(f, 'rb') as fh:
        content = fh.read()
    if not content.startswith(b'\xef\xbb\xbf'):
        with open(f, 'wb') as fh:
            fh.write(b'\xef\xbb\xbf' + content)
        print(f'BOM eklendi: {f}')
" <degisen-dosyalar>
```
**Not:** Binary dosyalar (resim, font, zip vb.) haric tutulur — sadece text dosyalar kontrol edilir.

### 5. Commit Mesaji Olustur
- Kullanici mesaj verdiyse ($ARGUMENTS) onu kullan
- Vermediyse diff'e bakarak kisa, anlasilir mesaj yaz
- **Insan yazmis gibi olmali** — AI ciktisi formati YASAK
- Turkce veya Ingilizce (projenin diline gore)
- Conventional commits formati opsiyonel ama tercih edilir (feat:, fix:, refactor:)
- **Migration varsa:** commit mesajinda acikca belirt. Ornek: `feat: kullanici tablosuna phone_number alani eklendi (migration gerekli)`
- Migration iceren commit'lerde mesajda su bilgiler yer almali:
  - Hangi tablo/alan etkileniyor
  - Migration dosyasinin adi (varsa)
  - Rollback gerektirip gerektirmedigi

### 6. Commit Kurallari
- `Co-Authored-By` satiri **EKLENMEZ** — ASLA
- `--no-verify` kullanilmaz (hook'lar atlanmaz)
- Commit mesaji HEREDOC ile olusturulur (format korumasi icin)

### 7. Commit Et ve Dogrula
```bash
git add <dosyalar>
git commit -m "mesaj"
git status  # dogrulama
```

### 8. Raporla
- Commit edilen dosyalar
- Haric tutulan governance dosyalari (varsa)
- Engellenen hassas dosyalar (varsa)
- BOM eklenen dosyalar (varsa)
- Migration bilgisi (varsa)
