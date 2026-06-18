---
name: security-scan
description: Sistematik guvenlik tarama proseduru - otomatik pattern arama ve risk tespiti
allowed-tools: Read, Grep, Glob
---

# Sistematik Guvenlik Taramasi

Kod degisikliklerini sistematik olarak tara. Her adimi sirasi ile uygula, atlama.

## Tarama Sirasi

### Adim 1: Hardcoded Secret Taramasi

Asagidaki pattern'leri tum degisen dosyalarda ara:

```
# API key, secret, password hardcoded mi?
Grep: (password|secret|api_key|apikey|token|credentials)\s*[:=]\s*["'][^"']+["']
Grep: (BEGIN\s+(RSA|DSA|EC|OPENSSH)\s+PRIVATE\s+KEY)
Grep: (ghp_|gho_|github_pat_|sk-|pk_live_|pk_test_|sk_live_|sk_test_)
```

Bulgu varsa → **Ciddiyet: Kritik**

### Adim 2: SQL/NoSQL Injection Taramasi

```
# Raw SQL string birlestirme
Grep: (query|execute|raw|sql)\s*\(.*(\+|`\$\{|f"|\.format)
Grep: (SELECT|INSERT|UPDATE|DELETE|DROP|ALTER).*(\+|concat|\$\{)

# NoSQL injection (MongoDB)
Grep: \$where|\$regex.*req\.(body|query|params)
```

Bulgu varsa → **Ciddiyet: Kritik**

### Adim 3: Command Injection Taramasi

```
# Shell komutu calistirma
Grep: (exec|spawn|system|popen|shell_exec|passthru)\s*\(
Grep: child_process
```

Bulgu varsa → kullanici girdisi akmasi kontrol et. Akiyorsa **Ciddiyet: Kritik**

### Adim 4: IDOR / Authorization Kontrolu

Degisen endpoint'lerde:
- Route parametresinden gelen ID (`:id`, `{id}`) ile kullanicinin kendi verisi mi kontrol ediliyor?
- `req.user.id` veya benzeri ile karsilastirma var mi?
- Admin endpoint'lerinde rol kontrolu var mi?

Bulgu varsa → **Ciddiyet: Yuksek**

### Adim 5: Hassas Veri Sizintisi

```
# Response'da hassas alan donuyor mu?
Grep: (password|passwordHash|hash|token|secret|ssn|creditCard)
```

DTO/response modellerinde bu alanlar var mi kontrol et. Entity dogrudan donduruluyorsa → **Ciddiyet: Yuksek**

### Adim 6: Rate Limiting Kontrolu

Degisen/eklenen endpoint'lerde:
- Rate limiting middleware/decorator/attribute uygulanmis mi?
- Ozellikle: login, register, forgot-password, public endpoint'ler

Eksikse → **Ciddiyet: Orta**

### Adim 7: CORS Kontrolu

```
# CORS konfigurasyonu
Grep: (cors|CORS|Access-Control-Allow-Origin)
Grep: origin.*(\*|null|reflect|req\.headers)
```

Wildcard, null, veya reflect varsa → **Ciddiyet: Yuksek**

### Adim 8: Mass Assignment Kontrolu

- Kullanici girdisi dogrudan entity/model'e bind ediliyor mu?
- `req.body` dogrudan ORM create/update'e gidiyorsa → **Ciddiyet: Orta**
- Admin-only alanlar (role, isAdmin, permissions) korunmus mu?

## Rapor Formati

Her bulgu icin:

```
GUVENLIK TARAMA RAPORU
======================
Taranan dosyalar: {liste}
Tarama tarihi: {tarih}

BULGU #{N}
----------
Ciddiyet: Kritik / Yuksek / Orta / Dusuk
Dosya: {dosya:satir}
Kategori: {Adim adi}
Risk: {ne tehdit var}
Kod: {ilgili kod parcasi}
Cozum: {ne yapilmali}

OZET
----
Kritik: {N} | Yuksek: {N} | Orta: {N} | Dusuk: {N}
Sonuc: {TEMIZ / SORUNLU — detay}
```

## Kurallar

- Tum 8 adimi uygula, "sorun yok gibi gorunuyor" deyip atlama
- False positive'leri de raporla ama "False Positive" olarak isaretle
- Kritik veya Yuksek bulgu varsa → SORUNLU sonucu ver, Team Lead'e escalate
- Tarama sonucu TEMIZ olsa bile rapor olustur (kanit)
