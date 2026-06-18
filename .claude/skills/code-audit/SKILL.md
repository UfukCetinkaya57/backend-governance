---
name: code-audit
description: Otonom codebase audit — kesif, tespit, raporlama. Tum projeyi tarar.
allowed-tools: Read, Grep, Glob, Bash
argument-hint: [hedef klasor (opsiyonel, varsayilan: proje koku)]
---

# Codebase Audit

Tum codebase'i sistematik olarak tara, sorunlari tespit et, rapor olustur.
Bu skill quality-gate'ten FARKLIDIR: quality-gate gorev bazli (degisen dosyalar), code-audit proje bazli (tum codebase).

## Ne Zaman Kullanilir

- Projeye ilk giristte genel saglik kontrolu
- Sprint sonu / milestone oncesi review
- Buyuk refactor oncesi durum tespiti
- Periyodik bakim (aylik/sprint bazli)

## Faz 1: Kesif (Yapi Haritasi)

1. Proje kok dizinini tara:
   - Klasor yapisi (Controller, Service, Repository, Model, DTO, Middleware)
   - Dosya sayilari ve buyuklukleri
   - Stack tespiti (csproj, package.json, composer.json)
   - Test dosyalarinin konumu ve sayisi

2. Giris noktalarini belirle:
   - API endpoint'leri (controller/route dosyalari)
   - Middleware pipeline
   - DI/IoC kayitlari
   - Migration dosyalari

3. Yapi haritasi ozeti olustur:
   ```
   src/
     Controllers/ (X dosya)
     Services/    (X dosya)
     Models/      (X dosya)
     ...
   tests/ (X dosya, coverage: ?)
   ```

## Faz 2: Tespit (Sorun Tarama)

Asagidaki kategorilerde sistematik tarama yap. Her kategori icin `grep` pattern'leri ve dosya okuma kullan.

### 2A: Guvenlik (bkz. `.claude/rules/guvenlik.md`)
- [ ] Hardcoded secret/password/API key
- [ ] SQL/NoSQL injection riski (raw query + string concatenation)
- [ ] IDOR potansiyeli (kullanici ID dogrudan parametre)
- [ ] Hassas veri response'da (password, token, hash alanlari)
- [ ] CORS wildcard (`*`) kullanimi
- [ ] Rate limiting eksikligi

```
Grep pattern'leri:
- password|secret|api.?key|token.*=.*["']
- raw.*query|exec.*sql|string.*format.*select
- cors.*origin.*\*
```

### 2B: Performans (bkz. `.claude/rules/kalite.md` Madde 6)
- [ ] N+1 sorgu potansiyeli (dongu icinde DB cagrisi)
- [ ] SELECT * kullanimi
- [ ] Pagination eksikligi (liste endpoint'leri)
- [ ] Index eksikligi (sik sorgulanan alanlar)
- [ ] Gereksiz eager loading veya eksik include

### 2C: Kod Kalitesi (bkz. `.claude/rules/kalite.md` Madde 9)
- [ ] Controller'da is mantigi (Controller → Service katmanlasma ihlali)
- [ ] Kullanilmayan import/using/require
- [ ] Tekrar eden kod bloklari (copy-paste)
- [ ] Cok buyuk dosyalar (>300 satir controller, >500 satir service)
- [ ] TODO/FIXME/HACK yorumlari

### 2D: Hata Yonetimi (bkz. `.claude/rules/kalite.md` Madde 7)
- [ ] Bos catch bloklari (exception yutma)
- [ ] Generic exception yakalama (catch-all)
- [ ] 500 hatasinda detay sizintisi
- [ ] Tutarsiz hata formati

### 2E: Test Durumu (bkz. `.claude/rules/test.md`)
- [ ] Test dosyasi olmayan service'ler
- [ ] Integration test olmayan endpoint'ler
- [ ] Assertion'siz testler
- [ ] Coverage orani (olculebiliyorsa)

### 2F: Veritabani (bkz. `.claude/rules/veri.md`)
- [ ] Rollback'siz migration
- [ ] FK/index eksikligi
- [ ] Isimlendirme ihlalleri (camelCase tablo/kolon)
- [ ] Cascade delete kuralsizligi

## Faz 3: Raporlama

Bulgulari asagidaki formatta raporla:

```
CODEBASE AUDIT RAPORU
=====================
Tarih: {tarih}
Proje: {proje adi}
Stack: {tespit edilen stack}

OZET
----
Toplam dosya: X
Toplam sorun: X (Kritik: X, Yuksek: X, Orta: X, Dusuk: X)

BULGULAR
--------
[KRITIK] {kategori} — {dosya:satir}
  Sorun: {aciklama}
  Oneri: {ne yapilmali}

[YUKSEK] {kategori} — {dosya:satir}
  Sorun: {aciklama}
  Oneri: {ne yapilmali}

...

GENEL SAGLIK
------------
Guvenlik:      [X/6 kontrol gecti]
Performans:    [X/5 kontrol gecti]
Kod Kalitesi:  [X/5 kontrol gecti]
Hata Yonetimi: [X/4 kontrol gecti]
Test:          [X/5 kontrol gecti]
Veritabani:    [X/4 kontrol gecti]

ONCELIKLI AKSIYONLAR
--------------------
1. {en kritik sorun + cozum onerisi}
2. {ikinci oncelikli}
3. {ucuncu oncelikli}
```

## Onemli Kurallar

- Bu skill KOD DEGISTIRMEZ — sadece tespit ve rapor
- Fix onerileri Team Lead'e sunulur, otomatik duzeltme YAPILMAZ
- Mevcut `kalite.md` ve `guvenlik.md` kurallarini referans alir, duplicate etmez
- Raporu kullaniciya goster, dosyaya kaydetme gereksiz (istenirse kaydedilir)
