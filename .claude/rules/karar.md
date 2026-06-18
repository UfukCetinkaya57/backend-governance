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
