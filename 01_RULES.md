# 01_RULES — Tüm Kural Dosyaları (.claude/rules/)
# backend-governance Project Knowledge Paketi
# 13 dosya | Alfabetik sıra | Ham içerik

═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/api.md ===
Boyut: 3.9 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# API TASARIM STANDARTLARI

## Ilke
API = sozlesme. Tutarsiz API, tutarsiz urun demektir.

---

## URL Yapisi

- Base: `/api/v1/{resource}`
- Resource isimleri: cogul, kebab-case, fiil yok
- Nested: `/api/v1/users/{userId}/orders`
- Filtreleme: query parameter (`?status=active&category=electronics`)

---

## HTTP Metodlari

| Metod | Amac | Idempotent |
|-------|------|------------|
| GET | Okuma | Evet |
| POST | Olusturma | Hayir |
| PUT | Tam guncelleme | Evet |
| PATCH | Kismi guncelleme | Garanti degil (*) |
| DELETE | Silme | Evet |

(*) PATCH, RFC 5789'a gore dogal olarak idempotent DEGILDIR.
Ornek: bir listeye eleman ekleyen PATCH, iki kez cagirilirsa iki eleman ekler.
Idempotent olmasi isteniyorsa endpoint'te acikca saglanmali.

---

## Response Formati

Proje genelinde tek format sec, karistirma.

### Secenek A: Envelope Pattern
```json
{
  "success": true,
  "data": { },
  "meta": {
    "pagination": { "page": 1, "limit": 10, "total": 100, "totalPages": 10 }
  }
}
```

### Secenek B: RFC 7807 ProblemDetails (hata icin)
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Email alani zorunludur",
  "instance": "/api/v1/users"
}
```

Karar: Proje basinda ADR ile belirle (bkz. mimari kurallari).

---

## Hata Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Girdi dogrulama hatasi",
    "details": [
      { "field": "email", "message": "Gecerli bir email adresi giriniz" }
    ]
  },
  "requestId": "uuid"
}
```

---

## Standart Hata Kodlari

| Kod | HTTP Status | Aciklama |
|-----|-------------|----------|
| VALIDATION_ERROR | 422 | Girdi dogrulama hatasi |
| UNAUTHORIZED | 401 | Kimlik dogrulanmadi |
| INVALID_TOKEN | 401 | Gecersiz token |
| TOKEN_EXPIRED | 401 | Token suresi dolmus |
| FORBIDDEN | 403 | Yetki yok |
| NOT_FOUND | 404 | Kaynak bulunamadi |
| ALREADY_EXISTS | 409 | Kaynak zaten mevcut |
| CONFLICT | 409 | Catisma |
| RATE_LIMIT_EXCEEDED | 429 | Istek limiti asildi |
| INTERNAL_ERROR | 500 | Sunucu hatasi |
| SERVICE_UNAVAILABLE | 503 | Servis kullanilamiyor |

---

## Rate Limiting

Rate limiting tum endpoint'lerde ZORUNLUDUR.

| Tur | Limit |
|-----|-------|
| Public endpoint | 60 / dakika |
| Authenticated | 1000 / saat |
| Admin | 10000 / saat |

Response header'lari (ornek: public endpoint):
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 55
X-RateLimit-Reset: {unix-timestamp}
```

---

## Pagination

Liste endpoint'lerinde pagination ZORUNLUDUR.

Iki yaklasim var — proje basinda karar ver (ADR):

### Offset Pagination (Basit, kucuk veri setleri)
```
?page=1&limit=10&sort=-createdAt
```
```json
{
  "page": 1, "limit": 10, "total": 247,
  "totalPages": 25, "hasNextPage": true, "hasPrevPage": false
}
```
Uyari: Buyuk veri setlerinde yavas (DB'de OFFSET O(n)), insert/delete sirasinda sayfa kaymasi olur.

### Cursor Pagination (Performansli, buyuk/gercek zamanli veri)
```
?limit=10&cursor={lastItemId}&sort=-createdAt
```
```json
{
  "data": [...],
  "cursor": { "next": "abc123", "prev": "xyz789" },
  "hasMore": true
}
```
Avantaj: DB'de index kullanir, veri degisse bile tutarli sayfalama.

**Varsayilan:** Offset ile basla. 10K+ kayit veya sik degisen veri varsa cursor'a gec.

---

## Idempotency

- GET, PUT, DELETE dogal olarak idempotent
- POST icin: `X-Idempotency-Key` header kullan
- Ayni key ile gelen tekrar istegi ayni response'u dondur

---

## Endpoint Kontrol Listesi

Her endpoint icin:
- [ ] RESTful URL
- [ ] Dogru HTTP metod
- [ ] Input validation (ZORUNLU)
- [ ] AuthN / AuthZ
- [ ] Error handling
- [ ] Rate limiting (ZORUNLU)
- [ ] Response format
- [ ] OpenAPI 3.1 dokumantasyonu
- [ ] Test (unit + integration)

Framework-spesifik detaylar (attribute, decorator, middleware) icin `stack/` dosyasina bak.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/backend.md ===
Boyut: 2.4 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# BACKEND ENGINEERING RULESET

## Zihniyet
Bu backend:
- Yuksek trafikli olabilir
- Hatali input alabilir
- Kotu niyetli kullanicilarla karsilasabilir

"Calisiyor" yeterli degildir.

---

## Zorunlu Sorgular

Her feature/degisiklik icin:
- Idempotency var mi?
- Timeout / retry / rate limit gerekir mi?
- Ayni istek iki kez gelirse ne olur?
- DB index ihtiyaci var mi?
- N+1 veya full scan riski?

---

## Katman Yapisi (Stack-Bagimsiz)

```
Controllers/  -> Sadece HTTP concern (request/response)
Services/     -> Is mantigi (business logic)
Repositories/ -> Veri erisimi (opsiyonel, ORM direkt Service'te de kullanilabilir)
Models/       -> Domain entity siniflari
DTOs/         -> Request/Response modelleri
Validators/   -> Input validation siniflari
Middleware/   -> Cross-cutting concern'ler
```

Kurallar:
- Controller'da is mantigi YAZILMAZ
- Service baska Service'i cagirabilir, ama dairesel bagimliligi onle
- Repository sadece veri erisimi yapar, is mantigi ICERMEZ
- DTO ve Entity asla ayni sinif OLMAZ

---

## Dependency Injection / IoC

Genel prensipler (stack-spesifik detaylar `stack/` dosyasinda):
- Somut sinif yerine interface/abstraction kullan
- Lifetime dogru sec (request-scoped vs singleton vs transient)
- Service kayitlari gruplanmis ve organize olmali
- Constructor injection tercih et, service locator anti-pattern'den kacin

---

## Veri Katmani (Genel)

- Migration varsa rollback stratejisi de yaz
- Soft / hard delete farkini sorgula
- Read-only sorgularda change tracking kapali olmali
- Sadece gerekli alanlari cek (SELECT * YASAK, projection kullan)
- N+1 onlemek icin eager loading / join kullan
- Buyuk veri setlerinde pagination zorunlu
- Detaylar: bkz. veri kurallari (otomatik yuklu)

---

## API

- Input validation zorunlu (her endpoint'te)
- Hata formati tutarli (proje genelinde tek format)
- AuthN != AuthZ mutlaka ayri kontrol et
- Idempotency key destegi (POST endpoint'leri icin)
- Detaylar: bkz. api ve guvenlik kurallari (otomatik yuklu)

---

## Performans

- O(n^2) riskleri belirt
- Cache ihtiyaci varsa yaz (hangi katmanda, ne kadar sureli)
- p95 latency dusunulmeden "tamamlandi" deme
- Hot path'lerde gereksiz allocation'dan kacin

---

## Test

- Service -> unit test
- API endpoint -> integration test
- Edge-case'leri ozellikle uret
- Detaylar: bkz. test kurallari (otomatik yuklu), stack-spesifik araclar: `stack/` dosyasina bak


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/context.md ===
Boyut: 2.3 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# CONTEXT YONETIMI

**Birincil muhatap: Team Lead.** Agent handoff, context dagitimi ve oturum yonetimi Team Lead'in sorumlulugundadir. Agent'lar icin gecerli kurallar (output ozetleme, dosyaya yazma) ilgili basliklar altinda belirtilmistir.

## Ilke
LLM'ler uzun konusmalarda bilgi kaybeder. Bunu bilerek calis.

---

## Lost-in-Middle Kurali

LLM'ler konusmanin **basini ve sonunu** iyi hatirlar, **ortasini** kaybeder.

- Kritik bilgi (karar, kisitlama, gereksinim) prompt'un **basina veya sonuna** yaz
- Uzun context'te onemli talimati ortaya gomme
- Agent handoff'larda en onemli bilgiyi ilk satirda ver

---

## Dort Kova Modeli

Context dolulugu arttiginda bu 4 stratejiyi uygula:

### 1. Write (Dosyaya Yaz)
- Uzun analiz sonuclarini dosyaya yaz, context'te tutma
- Plan, bulgu, ara sonuc → dosya veya memory'ye kaydet
- "Bunu hatirlayacagim" yerine "bunu dosyaya yaziyorum" de

### 2. Select (Filtrele)
- Agent'lara sadece gorevle ilgili bilgiyi gonder
- Tum context'i aktarma — handoff'ta sadece: ne yapildi, ne bekleniyor, nelere dikkat
- Gereksiz tool output'larini ozetleyerek aktar

### 3. Compress (Ozetle)
- Uzun tool sonuclarini ozetle, ham veriyi tasima
- 100 satirlik grep sonucu yerine "X dosyada Y pattern bulundu" de
- Tekrar eden bilgiyi bir kez yaz, referans ver

### 4. Isolate (Dagit)
- Bagimsiz gorevleri ayri subagent'lara ver — her biri temiz context'te calisir
- Paralel agent'lar context paylasMAZ — bu avantajdir, kirlilik yayilmaz
- Buyuk gorevleri bolumle: arastirma agent'i + uygulama agent'i

---

## Uzun Oturum Kurallari

- Context uzadiysa (cok sayida mesaj/tool ciktisi) → `memory/MEMORY.md` ve `proje/` dosyasini **yeniden oku**
- Onceki mesajlardaki kararlara guvenme — dosyadan dogrula
- Karmasik gorevlerde ara checkpoint'ler olustur: "Buraya kadar yapilan..." ozetini yaz
- Subagent sonuclari uzunsa ozet cikart, ham ciktiyi context'e birakma

---

## Agent Handoff Kurali

Bir agent'tan digerine gecerken aktarilacak bilgi **minimal ve yapilandirilmis** olmali:

```
1. Ne yapildi (2-3 cumle ozet)
2. Degisen dosyalar (liste)
3. Onceki agent bulgulari (varsa, ozetlenmis)
4. Bu agent'tan beklenen (net gorev)
5. Dikkat edilecekler (riskler, kisitlamalar)
```

Tum konusma gecmisini aktarma. Agent'in `Beklenen Input` bolumunu kontrol et, eksik bilgi gonderme.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/guvenlik.md ===
Boyut: 4.5 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# GUVENLIK & AUTH PROTOKOLU

## Ilke
Her kod potansiyel saldiri yuzeyidir.

---

## 8 Zorunlu Guvenlik Kontrolu

### 1. Injection
- SQL / NoSQL / command injection
- Parameterized query veya ORM kullan (raw string birlestirme YASAK)
- Kullanici girdisi dogrudan shell komutu veya sorguya girmemeli

### 2. Authorization Bypass
- AuthN (kimlik dogrulama) ve AuthZ (yetkilendirme) AYRI kontrol et
- Her endpoint'in auth durumu acikca belirtilmeli
- IDOR (Insecure Direct Object Reference) kontrol et:
  kullanici baska kullanicinin verisine erisebilir mi?

### 3. Sensitive Data Leakage
- Response'da sifre, token, hash, dahili ID yok
- DTO pattern ile sadece gerekli alanlar dondurulur
- Error mesajlarinda stack trace, DB detayi, dosya yolu yok

### 4. Rate Limiting & Brute Force
- Login endpoint'e rate limiting zorunlu (IP bazli)
- Brute force korumasi: exponential backoff (1s, 2s, 4s, 8s...) + CAPTCHA
- Hard account lockout YAPMA — saldirgan istedigi hesabi kilitler (DoS vektoru)
- Alternatif: 10+ basarisiz denemede gecici yavaslatma + kullaniciya bildirim
- Rate limit header'lari response'da

### 5. File Upload / Path Traversal / SSRF
- Upload: whitelist uzanti + content-type kontrol + boyut limiti
- Path: kullanici girdisi dosya yoluna dogrudan girmemeli (`../` korunmasi)
- SSRF: Dahili ag adreslerine istek yapilmasini engelle

### 6. CORS Misconfiguration
- Wildcard (`*`) origin production'da YASAK
- Explicit origin whitelist kullan (Origin header'ini reflect etme)
- Credentials ile CORS kullaniyorsan origin zorunlu
- `null` origin'e izin verme

### 7. Mass Assignment
- Kullanici girdisi dogrudan entity'ye bind edilmez
- DTO -> Entity mapping acikca tanimli olmali
- Admin-only alanlarin (role, isAdmin vb.) kullanici tarafindan set edilemeyeceginden emin ol

### 8. Transport Security
- HTTPS zorunlu — tum ortamlarda (staging + production)
- HTTP -> HTTPS redirect (301)
- HSTS header: `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- Security header'lar: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`

---

## Authentication Stratejisi

### JWT (Onerilen)
- Algoritma: RS256 (asimetrik) ZORUNLU coklu servis varsa. HS256 SADECE tek servis + tek secret ise kabul edilir.
- Access token: 15dk - 1 saat (hassas sistemlerde 15dk, genel uygulamalarda 1 saat)
- Refresh token: 14 gun (mutlak ust limit)
- Token'da minimum bilgi: sub (user id), role, iat, exp, iss, aud
- `iss` (issuer) ve `aud` (audience) dogrulamasi ZORUNLU

### Password Guvenligi
- **Onerilen:** argon2id (OWASP + NIST 2024 onerisi)
  - Parametreler: memory=19456 KiB, iterations=2, parallelism=1 (OWASP minimum)
- **Kabul edilir:** bcrypt (work factor: 12+)
  - Not: argon2id "salt rounds" kullanmaz, parametreleri farklidir
- Minimum 8 karakter, buyuk harf, kucuk harf, rakam, ozel karakter
- Sifre plain text HICBIR YERDE saklanmaz (log dahil)

### Token Yonetimi
- Refresh token DB'de hash'lenmis saklanir (SHA-256 yeterli, bcrypt gereksiz)
- **Refresh token rotation zorunlu:** her kullanimi yeni token uret, eskiyi invalidate et
- Eger eski token tekrar kullanilirsa -> tum token zincirini invalidate et (token hirsizligi tespiti)
- Mutlak token zinciri suresi: refresh token yenilense bile maks 30 gun sonra yeniden login zorunlu
- Logout'ta token invalidate edilir
- Token yenileme endpoint'i mevcut

---

## RBAC (Role-Based Access Control)

| Rol | Aciklama |
|-----|----------|
| USER | Standart kullanici |
| MODERATOR | Icerik yonetimi |
| ADMIN | Sistem yonetimi |
| SUPER_ADMIN | Tam yetki |

Roller hiyerarsik: SUPER_ADMIN > ADMIN > MODERATOR > USER
Her endpoint icin gerekli minimum rol belirtilmeli.

---

## Risk Raporu Formati

Guvenlik sorunu bulundugunda:

| Alan | Icerik |
|------|--------|
| Ciddiyet | Kritik / Yuksek / Orta / Dusuk |
| Risk | Ne tehdit var |
| Etki | Ne olabilir (veri kaybi, yetkisiz erisim, vb.) |
| Istismar Senaryosu | Nasil exploit edilir |
| Cozum | Ne yapilmali |
| Dogrulama | Cozumun calistigini nasil kanitlariz |

---

## Auth Endpoint'leri (Standart Set)

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
GET    /api/v1/auth/me
PATCH  /api/v1/auth/change-password
```

Opsiyonel:
```
POST   /api/v1/auth/verify-email
POST   /api/v1/auth/oauth/{provider}
GET    /api/v1/auth/sessions
DELETE /api/v1/auth/sessions/{id}
DELETE /api/v1/auth/account
```

Implementasyon detaylari icin `stack/` dosyasina bak.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/kalite.md ===
Boyut: 3.6 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

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


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/karar.md ===
Boyut: 3.7 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# MUHENDISLIK KARAR KAPISI

## Ilke
Her dogru cozum yapilmaya degmez.

---

## Zorunlu Sorular

Her cozum onerisi icin:
1. **Is degeri ne?** -> Kullaniciya / is'e somut faydasi nedir?
2. **Daha basiti yeterli mi?** -> Ayni sonucu daha az karmasiklikla alabilir miyiz?
3. **Kapsam faydayi asiyor mu?** -> Uygulama maliyeti elde edilecek fayadan buyuk mu?

---

## Basitlik Varsayimi

Varsayilan tercih: **en basit calisan cozum.**

Karmasik cozum ancak:
- Basit cozumun neden yetersiz oldugu
- **Somut ornekle** kanitlanirsa onerilir.

"Ileride lazim olabilir" gecerli bir gerekce DEGILDIR.

---

## Genel YAGNI Kontrolleri

- Paket/kutuphane eklemeden once: framework'un yerlesik ozelligi var mi?
- Middleware/interceptor yazmadan once: mevcut middleware kombine edilebilir mi?
- Abstraction katmani eklemeden once: su an birden fazla implementasyon var mi?
- Cache eklemeden once: sorgu optimize edildi mi?
- Microservice'e bolmeden once: modulleme yeterli mi?
- Event-driven pattern'den once: sync cagri isini goruyor mu?

---

## Gercek Dunya Anti-Pattern'leri

### "Repository Pattern Her Yerde" Tuzagi
**Durum:** ORM (EF Core, Prisma, Eloquent) zaten repository gorevi goruyor.
Ustune bir de generic IRepository<T> yazmak.
**Sonuc:** 3 katmanli indirection, hic bir ek fayda yok, debug zorlasiyor.
**Dogru karar:** ORM'i dogrudan Service'te kullan. Repository SADECE karmasik sorgular
baska yerlerde de tekrar kullanilacaksa anlamli.

### "Her Sey Event-Driven Olsun" Tuzagi
**Durum:** Basit CRUD islemleri icin bile message queue, event bus kurmak.
**Sonuc:** Debugging imkansiz, eventual consistency sorunlari, gereksiz altyapi.
**Dogru karar:** Sync cagri isini goruyorsa sync yap. Event-driven SADECE:
gercek async gereksinim (mail gonderme, bildirim) veya servisler arasi decoupling gerektiginde.

### "Microservice Cunku Modern" Tuzagi
**Durum:** 3 kisilik takim, tek uygulama, ama 5 microservice.
**Sonuc:** Network latency, deployment karmasikligi, distributed debugging cehennem.
**Dogru karar:** Monolith ile basla, moduler yapi kur. Microservice'e SADECE:
bagimsiz olcekleme gerektiren somut bir darbogazda gec.

### "Generic Her Sey" Tuzagi
**Durum:** BaseService<T>, BaseController<T>, GenericValidator<T> yazmak.
**Sonuc:** Her entity farkli is mantigina sahip, generic'ler ya yetersiz kalir ya da
if/switch ile dolup exception-based generics'e donusur.
**Dogru karar:** Tekrar eden kod 3. kez gorunene kadar generic yazma.
Copy-paste 2 kez kabul edilir, 3. de refactor et.

### "Config'e Tasiyalim" Tuzagi
**Durum:** Her degeri config/env'ye tasimak: pagination size, error mesajlari, regex'ler.
**Sonuc:** Config dosyasi 200 satir, kodu anlamak icin surekli config'e bakmak gerekiyor.
**Dogru karar:** Sadece ortama gore degisen degerler config'de olur
(DB connection, API key, feature flag). Is mantigi sabitleri kodda kalir.

---

## Karar Agaci

```
Yeni bir cozum/pattern/kutuphane onerisi geldiginde:

1. Mevcut kod/framework bunu zaten yapiyor mu?
   EVET -> Mevcut olanla devam et, yeni sey ekleme
   HAYIR -> 2'ye gec

2. Basit cozum (if/else, direkt cagri, inline) isini goruyor mu?
   EVET -> Basit cozumu uygula
   HAYIR -> 3'e gec

3. Bu karmasiklik bugunku somut bir sorunu cozuyor mu?
   EVET -> Uygula, ADR yaz (bkz. mimari/CLAUDE.md)
   HAYIR -> YAPMA. "Ileride lazim olur" gecerli degil.
```

---

## Karar Dokumantasyonu

Kucuk kararlar: commit mesajinda veya PR aciklamasinda belirt.
Buyuk kararlar: ADR yaz (bkz. mimari kurallari — otomatik yuklu).

Buyuk karar kriterleri:
- Geri donusu 1 saatten fazla suruyorsa
- Birden fazla dosya/modulu etkiliyorsa
- Takima/projeye uzun vadeli etkisi varsa


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/mimari.md ===
Boyut: 3.1 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# MIMARI TUTARLILIK

## Ilke
Bugunku hiz, yarinin borcu olmamali.

---

## 3 Mimari Kontrol

Her mimari degisiklikten once:
1. **Geri donusu zor mu?** -> Zorsa ADR yaz, onay al
2. **Domain sinirlarini ihlal ediyor mu?** -> Bir servisin baska servisin isini yapmasi
3. **Sorumluluklar net mi?** -> Her katman/sinif/modul tek sorumluluk

---

## Mimari Yaklasim

Mimari yaklasim proje bazinda `architect` tarafindan belirlenir. Asagidaki secenekler ve evrim yolu referanstir — sabit bir varsayilan YOKTUR.

### Baslangic Noktasi: Katmanli (Layered / N-Tier)

```
Controller (HTTP) -> Service (Is mantigi) -> Repository (Veri erisimi) -> Entity (Domain)
```

Not: Bu pattern bazen "Clean Architecture" olarak anilir ama gercek Clean Architecture
(Uncle Bob) ports/adapters ve dependency inversion ile daha katli kurallar icerir.
Biz burada pragmatik katmanli mimariyi kastediyoruz.

Katmanli mimaride kurallar:
- Bagimlilik yonu daima iceriden disariya (Entity hicbir seye bagimli degil)
- Controller sadece Service'i cagirir, Repository'yi dogrudan CAGIRMAZ
- Service baska Service'i cagirabilir, ama dairesel bagimliligi ONLE
- Cross-cutting concern'ler (logging, auth, cache) middleware/interceptor ile

### Evrim Yolu (her gecis ADR gerektirir)

1. **Katmanli mimari** (basla) → cogu proje icin yeterli
2. **Moduler monolit** (buyuyunce) → feature-based moduller, modul sinirlarinda interface
3. **Microservice** (somut olcekleme ihtiyacinda) → bagimsiz deploy gerektiren modul var

Proje profili ve gereksinimler hangi noktadan baslanacanigi belirler. `architect` bu karari verir ve ADR ile dokumante eder.

CQRS, Event Sourcing, Hexagonal Architecture gibi ileri pattern'ler icin somut gerekce + ADR zorunlu.

---

## ADR Zorunlu Durumlar

Asagidaki durumlarda Architecture Decision Record olusturulmali:
- Yeni pattern veya kutuphane ekleme
- Veri modeli etkisi / migration (ozellikle veri kaybeden)
- Uzun vadeli karar (framework, DB, mimari yaklasim)
- API tasarim degisikligi (breaking change)
- Guvenlik stratejisi degisimi
- Performans optimizasyon yaklasimlari
- Geri donusu zor herhangi bir karar

---

## ADR Formati

```markdown
# ADR-{N}: {Baslik}

**Tarih:** YYYY-MM-DD
**Durum:** Teklif | Kabul | Red | Kaldirildi | Degistirildi
**Karar Veren:** {isim/rol}

## Baglam
Ne sorunu cozuyoruz? Neden bu karar gerekli?

## Karar
Net bir ifadeyle ne karar verildi.

## Alternatifler

| Secenek | Artilari | Eksileri |
|---------|----------|----------|
| A | ... | ... |
| B | ... | ... |

## Gerekce
Neden bu secenegin secildigi.

## Sonuclar
- Olumlu: ...
- Olumsuz: ...
- Takip gerektiren: ...
```

---

## Anti-Pattern'ler

- God Service: Tek bir service'in her isi yapmasi -> bol
- Leaky Abstraction: Alt katman detaylarinin ust katmana sizmasi
- Circular Dependency: A -> B -> A bagimlilik dongusu
- Premature Abstraction: Tek kullanim icin interface/abstract sinif
- Config Sprawl: Konfigurasyonun kontrolsuz dagilmasi

Karar verme cercevesi ve YAGNI kontrolleri icin bkz. karar kurallari (otomatik yuklu).


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/operasyon.md ===
Boyut: 3.7 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# OPERASYONEL HAZIRLIK

## Ilke
Prod'da bozuldugunda yonetilemiyorsa eksiktir.

---

## 4 Zorunlu Soru

Her feature/deployment icin:
1. **Nasil fark ederiz?** -> Monitoring, alert, health check
2. **Hangi metrik alarm uretir?** -> Esik degerleri belirli
3. **Log'dan kok sebep bulunur mu?** -> Structured logging, correlation ID
4. **Rollback var mi?** -> Her deployment geri alinabilir olmali

---

## Monitoring Metrikleri

| Metrik | Esik | Aksiyon |
|--------|------|---------|
| API response (p95) | > 200ms | Alert |
| Error rate | > %0.5 | Alert (hedef < %0.1 — alarm esigi 5x: anlik spike'lari filtrelemek icin, 1dk pencere) |
| CPU kullanimi | > %80 | Alert |
| Memory kullanimi | > %85 | Alert |
| Uptime | < %99.9 | Kritik alert |
| DB connection pool | > %80 dolu | Alert |
| Queue depth | Proje bazli | Alert |

---

## Health Check

Iki seviye:
- `GET /health/live` → Uygulama calisiyor mu? (liveness)
- `GET /health/ready` → Istekleri alabilir mi? (readiness)

Not: Health check endpoint'leri `/api/v1/` prefix'i ALMAZ — altyapi endpoint'leridir, API degil.

Kontrol edilecekler:
- DB baglantisi
- Cache (Redis) baglantisi
- Disk alani (gerekiyorsa)
- Dis servis baglantilari (gerekiyorsa)

---

## Observability (Gozlemlenebilirlik)

Uc ayak: **Logs + Metrics + Traces**

### Distributed Tracing
- OpenTelemetry (OTel) standart — stack-bagimsiz, vendor-bagimsiz
- Her istek trace ID ile izlenebilir olmali (servisler arasi)
- Span'ler: HTTP istegi, DB sorgusu, dis servis cagrisi
- Export: Jaeger, Zipkin, Grafana Tempo veya cloud-native (Application Insights, Datadog, vb.)
- Stack-spesifik SDK'ler: `stack/` dosyasina bak

### Logging

- **Structured logging** zorunlu (JSON format)
- **Correlation ID** her istekte (request bazli izleme, OTel trace ID ile eslenebilir)
- **Request/Response** loglari (middleware ile)
- **Log seviyeleri:**
  - Info: Normal akis (basarili islemler)
  - Warning: Dikkat gerektiren durum (yavaslik, tekrar deneme)
  - Error: Hata (exception, basarisiz islem)
  - Fatal: Sistem cokmesi (uygulama calismaya devam edemez)

**YASAK loglama:**
- Sifre, token, API key
- Kredi karti bilgisi
- Kisisel saglik/kimlik verisi
- Session verileri

---

## Deployment

### Docker
- Multi-stage build (build + runtime ayri)
- Non-root user
- .dockerignore dosyasi mevcut
- Environment degiskenleri container disinda

### Environment Yonetimi
- Development: local config / user secrets
- Staging: environment variables / secret manager
- Production: Key Vault / secret manager (ASLA hardcoded degil)

### Deployment Stratejisi
- Blue-green veya rolling deployment
- DB migration deployment'tan ONCE ayri adimlarda
- Deployment sonrasi smoke test zorunlu

---

## Rollback Tetikleyicileri

Asagidakilerden biri olusursa hemen rollback:
- Kritik hata (500 error orani ciddi artis)
- Performans dususu (p95 > 500ms)
- Guvenlik acigi tespit
- Veri tutarsizligi

---

## Deployment Checklist

- [ ] Testler gecti (unit + integration)
- [ ] Code review onayli
- [ ] Migration hazir ve test edilmis
- [ ] Environment degiskenleri dogru
- [ ] Rollback plani var
- [ ] Monitoring aktif
- [ ] Deployment onay alindi
- [ ] Smoke test sonrasi "basarili" onaylanacak

---

## Runbook

Kritik akislar icin kisa mudahale adimlari hazirla:

```markdown
## {Akis Adi} - Mudahale Plani

Tetikleyici: {ne olursa}
Ciddiyet: Kritik / Yuksek / Orta
Mudahale adimlari:
1. ...
2. ...
3. ...
Rollback: {nasil}
Eskalasyon: {kime}
```

---

## Performans Hedefleri

| Metrik | Hedef |
|--------|-------|
| API Response (p95) | < 200ms |
| DB Query (avg) | < 50ms |
| Uptime | > %99.9 |
| Error Rate | < %0.1 |
| Test Coverage | > %70 |


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/qa.md ===
Boyut: 6.9 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# QA — FONKSIYONEL TEST PROTOKOLU

## Ilke
Kod calisiyor demek, dogru calisiyor demek degildir. Kullanici perspektifinden dogrulama ZORUNLU.

---

## QA vs Diger Roller — Sorumluluk Siniri

| Alan | Sorumluluk | Kim |
|------|------------|-----|
| Unit test yazma | Kod seviyesinde izole test | backend-developer |
| Integration test yazma | Endpoint/DB seviyesinde test | backend-developer |
| Test kodu kalitesi | Coverage, flaky, mock kurallari | quality-gate |
| Fonksiyonel test | Calisan sisteme karsi dogrulama | **qa-engineer** |
| Guvenlik testi | Injection, auth bypass, vb. | security-reviewer |

**Temel fark:** backend-developer ve quality-gate **koda** bakar, qa-engineer **calisan uygulamaya** bakar.

---

## Test Turleri

### 1. Smoke Test
- **Amac:** Deploy sonrasi temel fonksiyonlar calisiyor mu?
- **Kapsam:** Health check, login, ana liste endpoint'i
- **Sure:** < 5 dakika
- **Ne zaman:** Her deploy sonrasi (zorunlu)

### 2. Fonksiyonel Test (API)
- **Amac:** Endpoint'ler spesifikasyona uygun calisiyor mu?
- **Kapsam:** Happy path + error path + edge case
- **Ne zaman:** Yeni endpoint veya degisiklik sonrasi

### 3. E2E Test
- **Amac:** Kullanici akisi bastan sona dogru calisiyor mu?
- **Kapsam:** Tam akislar (register → login → islem → sonuc)
- **Ne zaman:** Tam kademede, buyuk feature sonrasi

### 4. Regression Test
- **Amac:** Onceki bug'lar tekrar etmiyor mu?
- **Kapsam:** Onceden bulunan ve fix'lenen bug'larin senaryolari
- **Ne zaman:** Her bug fix sonrasi (zorunlu)

### 5. Exploratory Test
- **Amac:** Yazili senaryolarin otesinde ne bozulabilir?
- **Kapsam:** Serbest kesif — tester'in deneyim ve sezgisine dayali
- **Ne zaman:** Yeni feature + tam kademede

---

## Test Plani Ogeleri

Her QA gorevi icin:
1. **Kapsam** — ne test edilecek, ne test edilmeyecek
2. **Onkosullar** — ortam hazir mi, test data var mi
3. **Test senaryolari** — numaralanmis, tekrarlanabilir
4. **Giris kriteri** — teste ne zaman baslanir (uygulama ayakta, quality-gate gecti)
5. **Cikis kriteri** — test ne zaman biter (tum senaryolar calistirildi, bug'lar raporlandi)
6. **Risk degerlendirmesi** — yuksek riskli alanlar oncelikli

---

## API Test Kontrol Listesi

Her endpoint icin asagidakiler test edilir:

### Happy Path
- [ ] Dogru input → dogru status code (200/201/204)
- [ ] Response body beklenen formatta
- [ ] Gerekli alanlar mevcut, gereksiz alanlar yok
- [ ] Pagination dogru calisiyor (liste endpoint'leri)
- [ ] Siralama/filtreleme calisiyor (varsa)

### Error Path
- [ ] Gecersiz input → 400 veya 422 + hata detayi
- [ ] Eksik zorunlu alan → validation hatasi
- [ ] Yetkisiz erisim → 401
- [ ] Yetersiz yetki → 403
- [ ] Var olmayan kaynak → 404
- [ ] Rate limit → 429
- [ ] Server hatasi → 500 (detay gizli)

### Edge Cases
- [ ] Bos string, null, cok uzun input
- [ ] Ozel karakterler (unicode, emoji, HTML tags)
- [ ] Sinir degerleri (0, max, negatif, ondalik)
- [ ] Ayni istek 2 kez (idempotency kontrolu)
- [ ] Concurrent istek (ayni kaynak, ayni anda)

### Guvenlik Yuzey Kontrolleri
- [ ] Auth gereken endpoint'e token'siz erisim → 401
- [ ] Baska kullanicinin verisine erisim denemesi → 403
- [ ] Response'da hassas veri yok (sifre, token, hash)
- [ ] Error mesajinda stack trace / DB detayi yok

---

## Bug Ciddiyet Siniflandirmasi

| Ciddiyet | Tanim | Etki | Ornek |
|----------|-------|------|-------|
| **Critical** | Core islevsellik tamamen bozuk | Uygulama kullanilamaz | Login calismaz, odeme crash |
| **Major** | Onemli feature bozuk, workaround var | Kullanici deneyimi ciddi etkilenir | Belirli rolde islem yapamaz |
| **Minor** | Kucuk sorun, islevsellik calisiyor | Rahatsiz edici ama engelleyici degil | Yanlis validation mesaji |
| **Trivial** | Kozmetik sorun | Islevsellige etkisi yok | Yazim hatasi, stil tutarsizligi |

**Severity vs Priority farki:**
- **Severity** = teknik etki (QA belirler)
- **Priority** = is onceligi (Team Lead / kullanici belirler)
- Dusuk severity + yuksek priority olabilir (ana sayfadaki yazim hatasi)
- Yuksek severity + dusuk priority olabilir (nadir kullanilan paneldeki crash)

---

## Go/No-Go Karar Matrisi

| Durum | Karar | Aciklama |
|-------|-------|----------|
| Tum testler PASS, bug yok | **GO** | Deployment onay |
| Sadece Minor/Trivial bug | **CONDITIONAL GO** | Team Lead karar verir, hotfix plani olabilir |
| Major bug acik | **NO-GO** | Team Lead gerekce ile CONDITIONAL GO'ya cevirebilir |
| Critical bug acik | **NO-GO** | Tartisma yok, fix ZORUNLU |

**Go/No-Go raporu Team Lead'e iletilir.** QA oneriyi verir, nihai karar Team Lead'indir.

Team Lead'in CONDITIONAL GO verebilecegi durumlar:
- Major bug workaround ile gecistirilebilir ve hotfix planlanmistir
- Bug sadece belirli bir edge case'i etkiler, core akis calisiyor
- Zaman kritik deployment (ama risk kabul edilerek)

Team Lead'in CONDITIONAL GO veremeyecegi durumlar:
- Critical bug (her zaman NO-GO)
- Veri kaybi riski
- Guvenlik acigi

---

## QA Metrikleri

| Metrik | Tanim | Hedef |
|--------|-------|-------|
| **Pass Rate** | Gecen test / Toplam test | > %95 |
| **Bug Escape Rate** | Production'a kacirilan bug / Toplam bug | < %10 |
| **Defect Density** | Bug sayisi / KLOC | Referans: 1-3 (iyi) |
| **Regression Pass Rate** | Regression testlerinde pass orani | %100 |

---

## Test Data Yonetimi

- Her test icin **taze data** olustur, onceki testin datasina bagimli olma
- Test sonrasi **state'i temizle** (olusturulan kayitlari sil veya rollback)
- **Minimal data** kullan — gerektigi kadar
- Hassas veriyi test data olarak **kullanma** (production veri kopyalama YASAK)
- Test data'yi **deterministic** tut — random deger, tarih/saat bagimliligini onle

---

## Playwright MCP Kullanim Kurallari

- Browser testi icin Playwright MCP kullan (navigate, click, fill, screenshot)
- API testi icin Playwright request context veya curl/httpie kullan
- Her fail icin **screenshot** veya **response body** kanit olarak ekle
- Test arasinda browser state'ini temizle (cookie, localStorage)
- Explicit wait kullan — hard-coded sleep YASAK

---

## Risk-Based Testing (Onceliklendirme)

Her seyi test etmek mumkun degilse, risk matrisi uygula:

| | Dusuk Etki | Orta Etki | Yuksek Etki |
|---|---|---|---|
| **Yuksek Olasilik** | Orta | Yuksek | **Kritik** |
| **Orta Olasilik** | Dusuk | Orta | Yuksek |
| **Dusuk Olasilik** | En dusuk | Dusuk | Orta |

**Oncelik sirasi:**
1. Proje dosyasindaki "Kritik Akislar"
2. Odeme / finansal islemler
3. Auth / yetkilendirme akislari
4. Veri degistiren islemler (POST/PUT/DELETE)
5. Veri okuyan islemler (GET)

---

Test disiplini ve test yapisi (Arrange-Act-Assert) icin bkz. test kurallari (otomatik yuklu).
API standartlari ve response formatlari icin bkz. api kurallari (otomatik yuklu).
Stack-spesifik test araclari icin bkz. `stack/` klasoru.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/stack.md ===
Boyut: 0.9 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# STACK TESPITI VE YUKLEME

## Kural
Projeye girildiginde aktif stack otomatik tespit edilir.
Tespit edildikten sonra ilgili stack dosyasi **okunmalidir** (otomatik yuklenmez).

## Tespit Mantigi

| Sinyal | Stack | Dosya |
|--------|-------|-------|
| `*.csproj` veya `*.sln` | .NET | Bu klasordeki `dotnet.md` dosyasini OKU |
| `package.json` + Express/Fastify | Node.js | Bu klasordeki `nodejs.md` dosyasini OKU |
| `composer.json` + Laravel | Laravel | Bu klasordeki `laravel.md` dosyasini OKU |

## Uygulama

1. Proje kok dizinindeki dosyalari tara (csproj, package.json, composer.json)
2. Stack'i belirle
3. Ilgili `stack/*.md` dosyasini **acikca oku** (Read)
4. Stack dosyasindaki arac ve pattern'leri uygula

Birden fazla stack tespit edilirse (monorepo), her biri icin ilgili dosya okunur.

## Yeni Stack Ekleme

Yeni stack destegi = bu klasore `yeni-stack.md` eklemek.
Ana governance dosyalari degismez — stack-bagimsizdir.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/surec.md ===
Boyut: 10.7 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# IS AKISLARI & SURECLER

## Feature Gelistirme Akisi

```
Planlama -> Tasarim -> Backend -> Test -> Review -> Deployment
```

### 1. Planlama
- Kapsam belirleme, kabul kriteri yazma
- Bagimliliklari tespit etme
- Oncelik ve effort tahmini

### 2. Tasarim
- DB sema tasarimi (gerekiyorsa)
- API sozlesmesi (endpoint, request/response format)
- ADR (mimari karar gerekiyorsa)

### 3. Backend Gelistirme
- Migration olusturma (bkz. veri kurallari)
- Endpoint implementasyonu (Controller -> Service -> Repository)
- Input validation (bkz. api kurallari)
- Auth/AuthZ uygulamasi (bkz. guvenlik kurallari)
- Error handling
- Rate limiting

### 4. Test
- Unit test (service katmani)
- Integration test (API endpoint'leri)
- Edge case ve hata senaryolari

### 5. Review
- Kalite kapisi kontrolu (bkz. kalite kurallari)
- Code review
- Sonuc: ONAYLI / DEGISIKLIK GEREKLI / REDDEDILDI

### 6. Deployment
- Staging'e deploy + smoke test
- Production'a deploy
- Post-deploy monitoring

Her faz arasi kalite kapisi gecisi zorunludur.

---

## Bug Fix Akisi

### 1. Raporlama
```
BUG-{N}: {Baslik}
Ciddiyet: Kritik / Yuksek / Orta / Dusuk
Yeniden uretme adimlari: ...
Beklenen davranis: ...
Gerceklesen davranis: ...
```

### 2. Triaj
| Ciddiyet | Yanit Suresi |
|----------|-------------|
| Kritik | Hemen (uretimi etkiler) |
| Yuksek | Ayni gun |
| Orta | Bu sprint |
| Dusuk | Backlog |

### 3. Duzeltme
- Root cause analizi (neden oldu, neden yakalanmadi)
- Minimal fix (sadece bug'i duzelt, refactor yapma)
- Regression test yaz (bug'in tekrar olusmayacagini kanitla)

### 4. Dogrulama
- Orijinal senaryo calisiyor
- Edge case'ler kontrol edildi
- Regression test gecti

---

## Code Review Sureci

### Sorun Seviyeleri

| Seviye | Anlami | Aksiyon |
|--------|--------|---------|
| **Blocker** | Merge'i engeller | Duzeltme zorunlu |
| **Major** | Onemli sorun | Duzeltme zorunlu |
| **Minor** | Kucuk sorun | Duzeltilmeli |
| **Suggestion** | Oneri | Opsiyonel |
| **Nitpick** | Kozmetik | Opsiyonel |

### Genel Kontroller
- Dogruluk: Is mantigi dogru mu?
- Kalite: Clean code, SOLID, katmanlasma
- Guvenlik: Auth, validation, injection korunmasi
- Performans: N+1, index, cache, p95
- Test: Yeterli kapsam, edge case, hata senaryosu

### Sonuc
- **ONAYLI** -> Merge edilebilir
- **DEGISIKLIK GEREKLI** -> Belirtilen sorunlar duzeltilmeli
- **REDDEDILDI** -> Temelden rework gerekli

---

## Escalation (Eskalasyon)

### Seviye 0: Kendi Basina Coz
- Minor kod hatalari, stil duzeltmeleri, dokumantasyon
- Bilinen pattern'lerin uygulanmasi

### Seviye 1: Senior / Tech Lead
- Teknik karar gerekli
- Standart disi durum
- Performans sorunu
- Kapsam genislemesi

### Seviye 2: Architect / Manager
- Kritik mimari karar
- Guvenlik endisesi
- Butce / kaynak karari
- Belirsiz gereksinimler

### Seviye 3: Acil Mudahale
- Production crash
- Guvenlik ihlali
- Veri kaybi riski
- Yasal zorunluluk

### Aciliyet Seviyeleri

| Aciliyet | Yanit Suresi |
|----------|-------------|
| Dusuk | 1-2 sprint |
| Orta | Bu sprint |
| Yuksek | Bugun |
| Kritik | Hemen |

---

## Git / Commit Kurallari

Git ve commit kurallari ana `CLAUDE.md` dosyasinda tanimlidir.
Team Lead commit islemlerini bu kurallara gore yonetir.

---

## Gorev-Kademe-Agent Eslestirme

Ana CLAUDE.md'den referans verilir. Karmasik gorevlerde kademe/agent secimi icin bu tablo kullanilir.

| Gorev Tipi | Kademe | Agent Akisi |
|------------|--------|-------------|
| Config / typo / docs | Hafif | `backend-developer` → bitti |
| Bug fix (tek dosya) | Hafif | `backend-developer` → bitti |
| Bug fix (coklu dosya) | Normal | `backend-developer` → `quality-gate` (hafif) |
| CRUD endpoint | Normal | `backend-developer` → `quality-gate` (hafif) |
| Basit feature | Normal | `backend-developer` → `quality-gate` (hafif) |
| Test yazma | Normal | `backend-developer` → `quality-gate` (hafif) |
| Performans iyilestirme | Normal | `backend-developer` → `quality-gate` (hafif) |
| Auth / yetkilendirme | Tam | `backend-developer` → `security-reviewer` → `quality-gate` |
| Yeni feature (buyuk) | Tam | `architect` → `backend-developer` → `security-reviewer` → `quality-gate` |
| DB migration | Tam | `backend-developer` → `quality-gate` (tam) |
| Deployment / DevOps | Normal | `devops` → bitti (harden mode'da → `security-reviewer` eklenir) |
| Mimari karar | — | `architect` → bitti |
<!-- QA-ENGINEER: Uygulama ayaga kalktiktan sonra aktif edilecek
| Auth / yetkilendirme | Tam | ... → `quality-gate` → `qa-engineer` |
| Yeni feature (buyuk) | Tam | ... → `quality-gate` → `qa-engineer` |
| QA testi (ayrica) | — | `qa-engineer` → bitti (uygulama ayakta olmali) |
-->

---

## Kademeli Pipeline Detay Kurallari

- Team Lead her kademede **is mantigi dogrulugu** kontrolu yapar (Code Review bolumu)
- `security-reviewer` SADECE tam kademede cagrilir — hafif/normal'de cagrilmaz
- `quality-gate` hafif kademede cagrilmaz, normal'de hafif kontrol, tam'da tam kontrol
<!-- QA-ENGINEER: Uygulama ayaga kalktiktan sonra aktif edilecek
- `qa-engineer` tam kademede ZORUNLU, normal'de opsiyonel (smoke test), hafif'te cagrilmaz
- `qa-engineer` calismasi icin uygulama ayakta olmali — kod yazilmadan ONCE cagrilmaz
-->
- **Paralel calisma:** Bagimsiz agent'lar ayni anda calistirabilir (ornek: `architect` plan yaparken `devops` ortam hazirlar)
- **Kademe yukseltme:** Team Lead gorevi incelerken risk farkederse kademeyi yukari cikarabilir (hafif → normal, normal → tam). Asagi indirmek YASAK.
- explore mode'da quality-gate opsiyonel (tum kademelerde)

---

## Feedback Dongusu Detay

Subagent'lar birbirleriyle direkt konusamaz. Tum iletisim Team Lead uzerinden gecer.

**Handoff kurali:** Bir agent'tan digerine gecerken Team Lead su bilgileri aktarir:
- Ne yapildi (degisen dosyalar, eklenen kodun ozeti)
- Onceki agent'in bulgulari (varsa)
- Nelere dikkat etmesi gerektigi
- Engineering mode (aktif mod)

Her subagent'in `.claude/agents/*.md` dosyasinda **"Beklenen Input"** bolumu var. Handoff sirasinda o listeyi kontrol et, eksik bilgi gonderme.

**Hafif kademe:**
```
1. backend-developer kodu yazar
2. Team Lead dogrular → bitti
```

**Normal kademe:**
```
1. backend-developer kodu yazar
2. Team Lead code review yapar
   ├── Sorun YOK → 3'e gec
   └── Sorun VAR → backend-developer'a geri gonder, duzelt
3. quality-gate (hafif kontrol)
   ├── GECTI → bitti
   └── KALDI → backend-developer'a geri gonder, duzelt, 2'ye don
```

**Tam kademe:**
```
1. backend-developer kodu yazar
2. security-reviewer inceler
   ├── Sorun YOK → 3'e gec
   └── Sorun VAR → backend-developer'a geri gonder, duzelt, 2'ye don
3. Team Lead code review yapar
   ├── Sorun YOK → 4'e gec
   └── Sorun VAR → backend-developer'a geri gonder, duzelt, 2'ye don
4. quality-gate (tam kontrol)
   ├── GECTI → bitti
   └── KALDI → backend-developer'a geri gonder, duzelt, 2'ye don
<!-- QA-ENGINEER: Uygulama ayaga kalktiktan sonra aktif edilecek
5. qa-engineer (fonksiyonel test — uygulama ayakta olmali)
   ├── GO → bitti
   ├── CONDITIONAL GO → Team Lead karar verir (asagidaki Go/No-Go bolumu)
   └── NO-GO → backend-developer'a geri gonder, fix, 2'ye don
-->
```

**Kurallar:**
- Herhangi bir agent sorun buldugunda, dongu bitmez — sorun duzeltilene kadar tekrar eder.
- **Max 3 dongu.** 3. dongude hala sorun varsa → kullaniciya raporla, karar iste. Sonsuz dongu YASAK.

---

<!-- QA-ENGINEER: Uygulama ayaga kalktiktan sonra aktif edilecek
## Go/No-Go Karari (Team Lead Rolu)

`qa-engineer` test sonuclarini raporlar ve Go/No-Go onerisi verir. Nihai karar Team Lead'indir.

| QA Onerisi | Team Lead Aksiyonu |
|------------|-------------------|
| **GO** | Deployment onay. Devam. |
| **CONDITIONAL GO** | Team Lead risk degerlendirir: hotfix plani var mi? Core akis calisiyor mu? Kabul veya NO-GO'ya cevirir. |
| **NO-GO** | Pipeline durur. `backend-developer`'a fix icin geri gonderilir. |

**Kurallar:**
- Critical bug = NO-GO. Team Lead bunu CONDITIONAL GO'ya ceviremez.
- Major bug = NO-GO. Ancak Team Lead gerekce ile (workaround var, core akis calisiyor, hotfix planli) CONDITIONAL GO'ya cevirebilir.
- CONDITIONAL GO karari verildiginde: kalan bug'lar, kabul gerekceleri ve hotfix plani kullaniciya raporlanir.
- Veri kaybi riski veya guvenlik acigi iceren bug = her zaman NO-GO.
-->

---

## Tamamlanma Protokolu Detay

Bir is "bitti" demeden once, kademeye gore:

**Hafif kademe:**
1. Team Lead degisikligi dogrular
2. Kisa ozet: ne yapildi, ne degisti
3. Proje Genel Durum Raporu

**Normal kademe:**
1. `quality-gate` hafif kontrol (sadece etkilenen maddeler)
2. Kanit Raporu — ne yapildi, gecen maddeler, kalan risk
3. Proje kontrolu (aktif proje dosyasi varsa)
4. Proje Genel Durum Raporu

**Tam kademe:**
1. `quality-gate` tam kontrol (11 nokta). Tek KAL = bitmemistir.
2. Kanit Raporu — ne yapildi, nasil dogrulandi, gecen maddeler, kalan risk
3. Proje kontrolu (aktif proje dosyasi varsa)
4. Proje Genel Durum Raporu

"Bitti" ancak kademenin gerektirdigi adimlar gecildikten sonra soylenir.

### Proje Genel Durum Raporu (ZORUNLU — her kademede)

Her gorev tamamlandiginda, kullanici sormadan asagidaki rapor gosterilir:

1. **Faz durumu** — Tum fazlar, her parcasinin durumu (Tamam / Eksik / Bekliyor)
2. **Siradaki adim** — Ne yapilacak, neye bagimli
3. **Blokerler** — Bekleyen kararlar, dis bagimliliklar, kimden bekleniyor

Amac: Kullanici projenin neresinde oldugunu her zaman bilmeli.
"Bitti" deyip susmak YASAK — kullanici bir sonraki adimi sormak zorunda kalmamali.

---

## Kural Evrimi (Ogrenen Sistem)

Governance kurallari statik degildir. Hatalardan, tekrar eden sorunlardan ve yeni kesiflerden ogrenilir.

### Tetikleyiciler
- Ayni hata 2. kez yapildi
- security-reviewer veya quality-gate tekrar eden bir sorun buldu
- Yeni bir pattern/anti-pattern kesfedildi
- Mevcut kural yetersiz veya yanlis cikti

### Protokol

```
1. TESPIT  — Sorun/ders ne? Hangi agent buldu?
2. FORMUL  — Team Lead kural onerisini yazar:
             - Hangi dosya etkilenir (agent .md veya governance .md)
             - Eklenecek/degisecek kural (tam metin)
             - Neden (somut ornek/kaynagi)
3. ONAY    — Kullaniciya sor: "Bu kurali ekleyelim mi?"
4. UYGULA  — Onaylanirsa ilgili dosyayi guncelle
```

### Kurallar
- Subagent'lar dogrudan dosya DEGISTIRMEZ — Team Lead'e raporlar, Team Lead onerir
- Kullanici onayi OLMADAN governance dosyasi degismez
- Her eklenen kural somut bir olaya dayanmali ("ileride lazim olur" gecersiz)
- Dosyalar sismemeli — ayni konudaki kurallar birlestirilir, eskiyen kurallar cikarilir


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/test.md ===
Boyut: 2.4 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# TEST DISIPLINI

## Ilke
Test = guvenin kaniti.

---

## 3 Zorunlu Soru

Her feature/degisiklik icin:
1. Nerede bozulur?
2. Edge-case ne?
3. Hata aninda davranis ne?

---

## Test Turleri

### Unit Test
- **Ne:** Is mantigi (service katmani)
- **Nasil:** Dis bagimliliklari mock'la, tek bir davranisi test et
- **Ne zaman:** Her service metodu icin

### Integration Test
- **Ne:** API endpoint'leri, DB islemleri, dis servis entegrasyonlari
- **Nasil:** Tam HTTP pipeline veya gercek DB ile
- **Ne zaman:** Her endpoint icin, her dis bagimlilikte

### Regression Test
- **Ne:** Daha once bulunan bug'lar
- **Nasil:** Bug'i yeniden ureten test yaz, fix'i dogrula
- **Ne zaman:** Her bug fix sonrasi (zorunlu)

---

## Test Yapisi

```
Arrange  -> Test ortamini hazirla (data, mock, config)
Act      -> Test edilecek aksiyonu calistir
Assert   -> Sonucu dogrula
```

Her test TEK bir davranisi test etmeli.
Test isimleri ne test ettigini acikca belirtmeli:
`Should_ReturnNotFound_When_UserDoesNotExist`

---

## Test Hiyerarsisi (Stack-Bagimsiz)

| Katman | Test Turu | Mock/Gercek |
|--------|-----------|-------------|
| Service | Unit | Dis bagimliliklari mock'la |
| Controller/Endpoint | Integration | Tam HTTP pipeline |
| Repository/DB | Integration | In-memory veya gercek DB |
| Middleware | Integration | Tam pipeline |
| Validator | Unit | Izole |

---

## Kapsam Hedefleri

| Metrik | Hedef |
|--------|-------|
| Unit test coverage | > %70 |
| Her endpoint'in integration testi | Zorunlu |
| Auth/permission testleri | Zorunlu |
| Edge case testleri | Her feature icin en az 3 |
| Hata senaryosu testleri | Her endpoint icin en az 1 |

---

## Junior Hatalari (Bunlari YAPMA)

1. **Sadece happy-path test**
   - Basarili senaryo yetmez, hata senaryolari da test et

2. **Asiri mock**
   - Her seyi mock'larsan gercek davranisi kacirir, test anlamsizlasir
   - Kural: sadece test sinirlarinin disindaki bagimliliklar mock'lanir

3. **Assertion'siz test**
   - Test calisiyor ama bir sey dogrulamiyor = test degil

4. **Test isolation eksik**
   - Testler birbirine bagimli olmamali
   - Her test kendi verisini olusturup temizlemeli

5. **Deterministic olmayan test**
   - Tarih, random deger, siraya bagimlilik = flaky test
   - Sabit degerler veya test clock kullan

---

Stack-spesifik test araclari ve framework'ler icin `stack/` dosyasina bak.


═══════════════════════════════════════════════════════════════
=== FILE: .claude/rules/veri.md ===
Boyut: 4.3 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# VERITABANI STANDARTLARI

## Ilke
Veri katmani = sistemin temeli. Index'siz sorgu, rollback'siz migration kabul edilmez.

---

## Isimlendirme Kurallari

| Oge | Kural | Ornek |
|-----|-------|-------|
| Tablo | snake_case, cogul | `users`, `order_items` |
| Kolon | snake_case | `first_name`, `created_at` |
| Primary Key | `id` (UUID v7 / ULID / auto-increment — bkz. PK secimi) | `id` |
| Foreign Key | `{entity}_id` | `user_id`, `order_id` |
| Boolean | `is_` veya `has_` prefix | `is_active`, `has_permission` |
| Timestamp | `_at` suffix | `created_at`, `updated_at`, `deleted_at` |
| Index | `ix_{tablo}_{kolon}` | `ix_users_email` |
| Unique | `uq_{tablo}_{kolon}` | `uq_users_email` |

---

## Zorunlu Alanlar

Her tabloda bulunmasi GEREKEN alanlar:

```
id          -> Primary Key (proje basinda karar ver, bkz. PK Secimi)
created_at  -> Olusturulma tarihi (default: now)
updated_at  -> Guncelleme tarihi (auto-update)
```

### PK Secimi (ADR ile karar ver)

| Tip | Avantaj | Dezavantaj | Ne Zaman |
|-----|---------|------------|----------|
| UUID v7 | Siralama dostu, distributed-safe, RFC 9562 (2024) | 128 bit, URL'de uzun | **Varsayilan oneri** |
| ULID | Siralama dostu, URL-safe (26 char) | Standart degil (RFC yok) | URL'de gosterilecekse |
| UUID v4 | Basit, yaygin | Random → index fragmentation | Legacy uyumluluk |
| Auto-increment | Kucuk, hizli, index dostu | Distributed'da catisma, tahmin edilebilir | Tek DB, internal |

Soft delete gerekliyse:
```
deleted_at  -> Silinme tarihi (nullable)
is_deleted  -> Boolean flag (opsiyonel, deleted_at yeterli olabilir)
```

---

## Migration Kurallari

- Her migration atomik olmali (tek bir degisiklik)
- Rollback / Down metodu ASLA bos birakilmaz
- Staging'de test edilmeden production'a alinmaz
- Data seed ayri migration/script ile yapilir
- Geri donulemez migration'lar (veri kaybeden) ADR gerektirir

---

## Index Stratejisi

Zorunlu index'ler:
- Primary key (otomatik)
- Foreign key'ler (ORM'e gore otomatik olmayabilir -> kontrol et)
- Unique constraint olan alanlar
- Sik WHERE kosulunda kullanilan alanlar
- ORDER BY'da kullanilan alanlar

Composite index:
- Sik birlikte sorgulanan alanlar icin
- Siralama onemli: en secici alan ilk siraya

Full-text search gerekiyorsa: DB'nin native destegini kullan (PostgreSQL tsvector, vb.)

---

## Query Optimizasyonu

- Sadece gerekli alanlari cek (SELECT * yasak, projection kullan)
- N+1 onlemek icin eager loading / join kullan
- Read-only sorgularda change tracking / dirty checking kapat
- Buyuk join'lerde split query degerlendir
- Pagination zorunlu (bkz. api kurallari — offset vs cursor secimi, otomatik yuklu)
- Count sorgulari ayri calistir (ana sorguyla karistirma)
- Raw SQL sadece performans zorunlulugunda, sebebi yorumla

---

## Iliski Tanimlari

- One-to-One: Acikca tanimla, gereksiz yere kullanma
- One-to-Many: FK parent tabloda degil, child tabloda olmali
- Many-to-Many: Junction table kullan, ekstra alanlar gerekiyorsa entity olarak modelle
- Cascade delete kurallarini acikca belirt (varsayilan kabul etme)

---

## Veri Tipleri

| Amac | Tip |
|------|-----|
| Primary Key | UUID v7 (onerilen) / ULID / BIGINT auto-increment |
| Kisa metin | VARCHAR(n) |
| Uzun metin | TEXT |
| Para/fiyat | DECIMAL(18,2) (FLOAT KULLANMA) |
| Boolean | BOOLEAN |
| Tarih | TIMESTAMP WITH TIMEZONE |
| JSON veri | JSONB (PostgreSQL) / NVARCHAR (SQL Server) |

---

## Transaction & Locking

- Birden fazla tabloyu etkileyen islemler transaction icinde olmali
- Isolation level: varsayilan READ COMMITTED yeterli, gerekmedikce degistirme
- Pessimistic lock (SELECT FOR UPDATE) sadece race condition riski varsa
- Optimistic lock (version/rowversion kolonu) concurrent update senaryolarinda
- Long-running transaction YASAK — islem suresini kisa tut
- Deadlock onleme: her zaman ayni sirada tablo/kaynak kilitle

---

## Kontrol Listesi

- [ ] Isimlendirme kurallarina uygun
- [ ] PK ve audit alanlari (created_at, updated_at) mevcut
- [ ] Soft delete karari alinmis
- [ ] FK'ler tanimli
- [ ] Gerekli index'ler eklenmis
- [ ] Migration olusmus ve rollback yazilmis
- [ ] Iliskiler acikca tanimlanmis
- [ ] Cascade kurallar belirli

ORM-spesifik detaylar (EF Core, Prisma, Eloquent) icin `stack/` dosyasina bak.

