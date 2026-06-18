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
