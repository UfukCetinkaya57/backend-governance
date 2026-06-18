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
