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
