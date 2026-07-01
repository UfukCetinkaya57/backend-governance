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

### 4. Dosya Encoding Kontrolu (dosya-tipine gore)

BOM politikasi dosya tipine gore AYRISIR. "Hepsine BOM ekle" YANLIS — config
dosyalarini kirar (bkz. memory feedback_no_bom_tool_config).

**BOM-LU olmali** (ilk 3 byte EF BB BF):
- `*.cs`  (.NET / Visual Studio BOM'lu UTF-8 uretir, repo normu)

**BOM-SUZ olmali** (BOM parser'i / araci kirar):
- `*.yml`, `*.yaml`, `*.json`, `.env`, `.env.*`
- `Dockerfile`, `docker-compose*.yml`, `Caddyfile`
- `*.sh`, `*.sql`, `*.csproj`, `*.props`, `*.targets`
- `*.md` (governance dahil)

Kontrol: `head -c3 <dosya> | od -An -tx1`  (ef bb bf => BOM var)

Duzeltme (tip-ayrimli: .cs'e ekle, config'ten cikar — iki AYRI cagri):
```bash
python3 -c "
import sys
mode = sys.argv[1]   # 'add' (.cs icin) veya 'strip' (config icin)
for f in sys.argv[2:]:
    c = open(f,'rb').read()
    has = c.startswith(b'\xef\xbb\xbf')
    if mode=='add' and not has:
        open(f,'wb').write(b'\xef\xbb\xbf'+c); print('BOM eklendi:', f)
    if mode=='strip' and has:
        open(f,'wb').write(c[3:]); print('BOM cikarildi:', f)
" add   <degisen .cs dosyalari>
# ayri cagri config icin:
# python3 -c "...ayni script..." strip <degisen config dosyalari>
```
**Not:** Binary dosyalar (resim, font, zip) haric. BOM islemi eol'e DOKUNMAZ
(yalniz ilk 3 byte'a bakar). `.gitattributes` KULLANILMIYOR (bilincli — renormalize
riski; bu kontrol commit oncesi tek enforcement noktasi).

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
