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
