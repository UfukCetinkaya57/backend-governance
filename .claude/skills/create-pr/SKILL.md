---
name: create-pr
description: Governance kurallarına uygun Pull Request olusturur
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [base branch (opsiyonel, varsayilan: master/main)]
---

# Governance PR Olusturma

Pull Request'i governance kurallarına uygun olustur.

## Adimlar

### 1. Branch ve Durum Kontrolu

```bash
git status
git branch --show-current
git log --oneline -5
```

- Mevcut branch'in adini al
- Commit edilmemis degisiklik varsa UYAR (once `/commit` kullan)
- Base branch'i belirle: arguman verilmisse onu kullan, yoksa `master` veya `main`
- Stale-branch kontrolu: `git fetch origin && git rev-list --count HEAD..origin/main`
  Sonuc 0 DEGILSE branch bayat main'den acilmis olabilir. Kullaniciya UYAR
  ("branch bayat olabilir, gerekirse `git rebase origin/main`"), zorla engelleme — sadece uyar.

### 2. Degisiklikleri Analiz Et

```bash
git log {base-branch}..HEAD --oneline
git diff {base-branch}...HEAD --stat
```

- Base branch'ten bu yana tum commit'leri listele
- Degisen dosya sayisi ve turlerini belirle
- Governance dosyalarini filtrele (PR'a dahil olmamali)

### 3. PR Tipi Otomatik Tespit

Commit mesajlarindan PR tipini cikart:
- `feat:` → Feature
- `fix:` → Bug Fix
- `refactor:` → Refactoring
- `docs:` → Documentation
- `test:` → Test
- Karisik → Mixed (en baskin tipi sec)

### 4. Baslik Olustur

- Maksimum 70 karakter
- Format: `{tip}: {kisa aciklama}`
- Insan yazmis gibi, AI formati YASAK
- Turkce veya Ingilizce (projenin diline gore)

### 5. Body Olustur

```markdown
## Ozet
- {1-3 madde: ne yapildi, neden yapildi}

## Degisiklikler
- {degisen dosya/modul listesi, gruplanmis}

## Test Plani
- [ ] {test adimlari}

## Governance Pipeline
- Engineering Mode: {mode}
- Kademe: {hafif/normal/tam}
- Quality Gate: {GECTI/KOSULLU GECTI/calistirilmadi}
- Security Review: {TEMIZ/bulgular var/calistirilmadi}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 6. Governance Kontrolleri

PR olusturmadan once:
- [ ] Governance dosyalari (.claude/, CLAUDE.md, backend-governance/, proje/) commit'lerde YOK
- [ ] Hassas dosyalar (.env, credentials, *.pem, *.key) commit'lerde YOK
- [ ] Kademe geregi quality-gate calistirilmissa sonucu body'ye ekle
- [ ] Tam kademede security-reviewer calistirilmissa sonucu body'ye ekle

Governance dosyasi commit'lerde varsa UYAR ve devam etme.

### 7. PR Olustur

```bash
gh pr create --title "{baslik}" --body "$(cat <<'EOF'
{body}
EOF
)"
```

- Push yapilmamissa once push et: `git push -u origin {branch}`
- PR URL'sini raporla
- Draft olarak acmak icin: `--draft` flag'i ekle

### 8. Raporla

- PR URL'si
- Dahil edilen commit sayisi
- Degisen dosya sayisi
- Haric tutulan governance dosyalari (varsa)
- Governance pipeline durumu
