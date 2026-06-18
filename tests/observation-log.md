# Gozlem Logu

## Nasil Kullanilir

Gercek projelerde agent calismasi sirasinda dikkat ceken seyleri not et.
Ayni sorun 2. kez gorunurse → governance guncellemesi tetiklenir (bkz. CLAUDE.md "Kural Evrimi").

---

## Log

### Sablon

```
## [TARIH] - [PROJE] - [AGENT]

**Senaryo:** Ne yapiliyordu?
**Gozlem:** Ne oldu? (iyi veya kotu)
**Beklenen:** Ne olmasi gerekirdi?
**Tekrar:** Bu sorun daha once goruldu mu? (ilk / 2. kez / tekrar eden)
**Aksiyon:** Ne yapildi veya yapilmali?
```

---

### Ornek Giris

## 2026-03-21 - sales-app-api - security-reviewer

**Senaryo:** Login endpoint review
**Gozlem:** Rate limiting eksikligini tespit etti ama IDOR'u kacirdi
**Beklenen:** Her ikisini de bulmasi gerekirdi
**Tekrar:** Ilk
**Aksiyon:** Izle. 2. kez olursa security-reviewer prompt'una IDOR vurgusu ekle.

---

## 2026-03-22 - governance (eval) - backend-developer

**Senaryo:** Pagination ekleme gorevi — ADIM 0 "first run the tests" kurali test edildi
**Gozlem:** Agent ADIM 0'i atladi, stack-loader ile basladi. 3 farkli prompt denendi, hicbirinde testleri once calistirmadi.
**Beklenen:** Ilk is olarak mevcut testleri calistirmasi gerekirdi
**Tekrar:** Ilk (kural yeni eklendi)
**Aksiyon:** Eval ortaminda test edilemiyor (gercek dosya/test yok). Gercek projede (sales-app, memory-box) ilk kod gorevinde izlenecek. 2. kez atlarsa prompt daha da guclendiirilecek veya farkli yaklasim denenecek.

## 2026-03-22 - governance (eval) - qa-engineer

**Senaryo:** Register endpoint fonksiyonel test plani — manuel test yontemleri test edildi
**Gozlem:** 14 senaryo yazdi, curl ornekleri verdi, mass assignment + hassas veri kontrolu dahil. Manuel test yontemleri tablosunu kullanmadi ama curl/httpie yontemini dogal olarak uyguladi.
**Beklenen:** Manuel test yontemleri referansini kullanmasi beklendi — dogrudan uyguladi, referans tablosuna bakmadi ama davranis dogru.
**Tekrar:** Ilk
**Aksiyon:** Sorun yok. Davranis beklentiye uygun.

<!-- Yeni gozlemleri asagiya ekle -->
