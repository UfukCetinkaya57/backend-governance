# BACKEND KALITE KAPISI

## Ilke
Kalite kapisi gecilmeden kod merge edilmez. Istisna yok.

---

## 11 Nokta Kontrol Listesi

### 1. API Standartlari
- [ ] URL RESTful ve kebab-case (`/api/v1/{resource}`)
- [ ] HTTP metodlari dogru (GET okuma, POST olusturma, vb.)
- [ ] Response formati tutarli (envelope veya ProblemDetails)
- [ ] Status kodlari dogru (200/201/204/400/401/403/404/422/429/500)
- [ ] Hata kodlari standart (VALIDATION_ERROR, UNAUTHORIZED, vb.)
- [ ] Versiyonlama uygulanmis
- [ ] Pagination (liste endpoint'leri)

### 2. Veritabani
- [ ] Isimlendirme kurallarina uygun (snake_case, cogul)
- [ ] PK tanimli (UUID v7 / ULID / auto-increment — ADR ile kararli)
- [ ] CreatedAt / UpdatedAt alanlari mevcut
- [ ] Soft delete karari alinmis (gerekiyorsa DeletedAt)
- [ ] FK'ler ve indexler tanimli
- [ ] Migration olusmus, rollback yazilmis

### 3. Input Validation
- [ ] Her endpoint'te validation uygulanmis
- [ ] Tip, uzunluk, format kontrolleri var
- [ ] Zorunlu alan kontrolleri var
- [ ] Validation hatalari detayli mesaj donduruyor
- [ ] Injection korunmasi saglanmis

### 4. Authentication & Authorization
- [ ] Korunmasi gereken endpoint'lere auth uygulanmis
- [ ] Public endpoint'ler acikca isaretlenmis
- [ ] Rol/permission kontrolleri mevcut
- [ ] Token dogrulama calisiyor
- [ ] Hassas endpoint'lerde ekstra guvenlik var

### 5. Guvenlik
- [ ] Password hashing uygulanmis (argon2id onerilen, bcrypt kabul edilir)
- [ ] Hassas veri response'da yok (sifre, token, vb.)
- [ ] Rate limiting aktif
- [ ] CORS dogru yapilandirilmis
- [ ] Error mesajlari bilgi sizintisi icermiyor

### 6. Performans
- [ ] API response < 200ms (p95)
- [ ] DB query < 50ms (avg)
- [ ] N+1 sorgu yok
- [ ] Read sorgularda gereksiz overhead yok (ORM'e ozel: bkz. `stack/`)
- [ ] Caching uygulanmis (gerekli yerlerde)
- [ ] Pagination ile buyuk veri setleri

### 7. Hata Yonetimi
- [ ] Global exception handler mevcut
- [ ] Tutarli hata formati
- [ ] 500 hatalarinda detay gizli (kullaniciya generic mesaj)
- [ ] Hatalar loglanmis
- [ ] Hassas veri loglarda yok

### 8. Logging
- [ ] Structured logging uygulanmis
- [ ] Request/Response loglari var
- [ ] Correlation ID mevcut
- [ ] Hassas veri loglanmiyor (sifre, token, kart no)
- [ ] Log seviyeleri dogru (Info, Warning, Error, Fatal)

### 9. Kod Kalitesi
- [ ] Controller -> Service -> Repository katmanlasma
- [ ] Is mantigi Service katmaninda
- [ ] DI dogru kullanilmis
- [ ] Kullanilmayan kod temizlenmis
- [ ] Asenkron islemler dogru handle edilmis

### 10. Dokumantasyon
- [ ] API dokumantasyonu (OpenAPI 3.1) guncel
- [ ] Her endpoint'in response tipleri belirtilmis
- [ ] Error kodlari dokumante edilmis
- [ ] Rate limit bilgisi mevcut

### 11. Test
- [ ] Unit testler (service katmani)
- [ ] Integration testler (API endpoint'leri)
- [ ] Edge case ve hata senaryolari
- [ ] Auth/permission testleri
- [ ] Test coverage > %70 (branch coverage tercih, sadece line coverage yeterli degil)
- [ ] Regression test: her bug fix sonrasi ZORUNLU (bug'i yeniden ureten test yazilmali)
- [ ] Deterministic olmayan test YASAK (tarih, random, siraya bagimlilik = flaky test)

---

## Sonuc

| Sonuc | Anlami |
|-------|--------|
| **GECTI** | Tum kontroller tamam, merge edilebilir |
| **KOSULLU GECTI** | Minor sorunlar var, paralel duzeltilir |
| **KALDI** | Blocker/major sorun var, rework gerekli |

Test stratejisi, mock kurallari ve detayli test standartlari icin test kurallarina basvur (otomatik yuklu).
Stack-spesifik arac ve kutuphane detaylari icin `stack/` klasorune basvur.
