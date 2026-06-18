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
