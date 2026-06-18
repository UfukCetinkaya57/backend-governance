---
name: governance-eval
description: Governance sistemini 3 katmanda denetler (yapisal, tutarlilik, davranissal). Tek komutla calisir, scorecard uretir, onceki skorla karsilastirir.
---

# Governance Denetim Sistemi

## Temel Kural

```
BU SKILL CALISTIRILDIGINDA 3 KATMAN SIRASIYLA UYGULANIR. ATLAMA YOK.
```

Kullanici "sistemi denetle" veya `/governance-eval` dediginde bu prosedur baslar.

---

## Katman 1: Yapisal Kontrol (Deterministik)

Dosya/dizin tarayarak kontrol. Insan yargisi gerektirmez.

### 1.1 Agent Butunlugu

`.claude/agents/` altindaki tum `.md` dosyalarini tara. Her biri icin:

- [ ] Dosya mevcut ve bos degil
- [ ] Frontmatter alanlari tam: `name`, `description`, `tools`, `model`, `maxTurns`, `memory`
- [ ] `skills:` alani varsa, listelenen her skill `.claude/skills/` altinda klasor olarak mevcut mu

**Beklenen agent'lar:** architect, backend-developer, security-reviewer, quality-gate, devops, qa-engineer

Eksik agent = FAIL. Fazla agent = bilgi (PASS ama not dusulur).

### 1.2 Skill Baglantisi

`.claude/skills/` altindaki tum klasorleri tara. Her biri icin:

- [ ] `SKILL.md` dosyasi mevcut ve bos degil
- [ ] Frontmatter'da `name` ve `description` var
- [ ] En az bir agent'in `skills:` alaninda referans ediliyor VEYA Team Lead skill'i (commit, create-pr, yeni-proje, code-audit, governance-eval)

**Orphan tespiti:** Hicbir agent'a bagli olmayan ve Team Lead skill'i de olmayan skill = FAIL.

### 1.3 Rule Dosyalari

`.claude/rules/` altindaki tum `.md` dosyalarini tara:

- [ ] Her dosya mevcut ve bos degil (en az 10 satir)
- [ ] Dosya sayisi beklenenle uyumlu

**Beklenen rule dosyalari:** api, backend, context, guvenlik, kalite, karar, mimari, operasyon, qa, stack, surec, test, veri (13 dosya)

### 1.4 Capraz Referans

Agent ve skill dosyalarindaki `bkz.`, `stack/`, `surec/`, `.claude/rules/` referanslarini grep'le. Her referansin isaret ettigi dosya mevcut mu kontrol et.

- [ ] Kirik referans yok (referans edilen dosya mevcut)

### 1.5 Test Altyapisi

- [ ] `tests/agent-evals.md` mevcut ve bos degil
- [ ] `tests/observation-log.md` mevcut
- [ ] `tests/fixtures/` klasoru mevcut ve icinde dosya var

### Katman 1 Skorlama

Her kontrol maddesi 1 puan. PASS = 1, FAIL = 0.
`Katman1_Skor = gecen / toplam`

---

## Katman 2: Icerik Tutarliligi (Grep-bazli)

Kurallar arasi celiskii ve eksiklik taramasi.

### 2.1 Guvenlik Kapsami

`guvenlik.md` dosyasindaki 8 zorunlu kontrolu oku:
1. Injection
2. Authorization Bypass
3. Sensitive Data Leakage
4. Rate Limiting & Brute Force
5. File Upload / Path Traversal / SSRF
6. CORS Misconfiguration
7. Mass Assignment
8. Transport Security

Her birinin `security-reviewer.md` prompt'unda dogrudan veya dolayli referans edilip edilmedigini kontrol et.

- [ ] 8/8 kapsam → PASS
- [ ] 6-7/8 → PARTIAL
- [ ] <6 → FAIL

### 2.2 Kalite Kapsami

`kalite.md` dosyasindaki 11 maddelik kontrol listesini oku. Her maddenin `quality-gate.md` prompt'unda karsiligi var mi kontrol et.

- [ ] 11/11 → PASS
- [ ] 9-10 → PARTIAL
- [ ] <9 → FAIL

### 2.3 API Kurallari Kapsami

`api.md` dosyasindaki temel standartlari kontrol et:
- Rate limiting zorunlulugu
- Pagination zorunlulugu
- Input validation zorunlulugu
- Idempotency (POST)
- Response formati tutarliligi

Bu kurallarin `backend-developer.md` prompt'unda gecip gecmedigini kontrol et.

### 2.4 Pipeline Tutarliligi

`surec.md` dosyasindaki kademe tanimlari (hafif/normal/tam) ile `CLAUDE.md`'deki kademe tanimlarini karsilastir.

- [ ] Kademe sayisi ayni
- [ ] Agent akislari tutarli
- [ ] Kademe secim kriterleri celismiyor

### 2.5 Skill-Kural Ortusme

Her skill'in icerigi ile ilgili rule dosyasinin icerigini karsilastir. Ayni konuda farkli talimat var mi?

Ornek kontrol: `tdd` skill'i "test once" diyor — `test.md` rule'u bununla celisiyor mu?

- [ ] Celisiki yok → PASS
- [ ] Celisiki var → FAIL (detay belirt)

### Katman 2 Skorlama

Her kontrol maddesi 1 puan. PARTIAL = 0.5.
`Katman2_Skor = gecen / toplam`

---

## Katman 3: Davranissal Test (Dinamik Senaryo Uretimi)

**ONEMLI:** Bu katman Katman 1-2 bulgularina DAYANIR. Sabit senaryo listesi KULLANMAZ.

### Adim 1: Bulgulari Topla

Katman 1-2'deki FAIL ve PARTIAL sonuclari listele. Bunlar "kapsam bosluklari."

### Adim 2: Tuzak Kodu Uret

Her bulgu icin kisa bir kod parcasi (20-40 satir) uret. Kod su ozelliklere sahip olmali:
- Bulgunun isaret ettigi zayifligi ICERMELI
- Ilk bakista makul gorunmeli (bariz hata degil)
- Tek bir dosyada, bagimsiz calisabilir olmali

**Uretim Tablosu:**

| Bulgu Tipi | Tuzak Kodu Icerigi | Hedef Agent |
|------------|-------------------|-------------|
| Guvenlik kapsam boslugu (ornek: IDOR eksik) | Baska kullanicinin verisine erisebilen endpoint | security-reviewer |
| Kalite kapsam boslugu (ornek: N+1 eksik) | Acik N+1 query iceren service | quality-gate |
| API kurali eksik (ornek: rate limit) | Rate limiting'siz login endpoint | backend-developer |
| Migration kurali eksik | Bos rollback'li migration | backend-developer |
| Validation eksik | Input validation'siz endpoint | backend-developer |
| Genel (bulgu yoksa) | Karisik 2-3 hata iceren kod | security-reviewer + quality-gate |

### Adim 3: Agent'a Ver

Uretilen kodu ilgili agent'a "bu kodu review et" talimatiya ver.
Agent ciktisini al.

### Adim 4: Skorla

Her tuzaktaki hedef hata icin:
- Agent BULDU → PASS (1 puan)
- Agent KISMEN buldu (dogru alan, yanlis detay) → PARTIAL (0.5 puan)
- Agent KACIRDI → FAIL (0 puan)

**Agirlik:**
- Guvenlik hatalari: x3 (Critical)
- Veri butunlugu / migration: x2 (High)
- Diger: x1 (Normal)

### Senaryo Sayisi

- Katman 1-2'de FAIL/PARTIAL varsa: her bulgu icin 1 senaryo (maks 5)
- Katman 1-2 tamamen PASS ise: genel kapsamdan 2 rastgele senaryo (smoke test)
- Minimum: 2, Maksimum: 5

### Katman 3 Skorlama

`Katman3_Skor = (agirlikli_gecen / agirlikli_toplam)`

---

## Genel Skor Hesaplama

```
Genel Skor = (Katman1_Skor + Katman2_Skor + Katman3_Skor) / 3 × 100
```

Uc katmanin agirlikli ortamalasi yuzde olarak.

### Esikler

| Skor | Durum | Anlam |
|------|-------|-------|
| 90%+ | SAGLAM | Sistem iyi calisiyor, buyuk sorun yok |
| 70-89% | YETERLI | Iyilestirme alanlari var ama islevsel |
| 50-69% | ZAYIF | Ciddi eksikler, mudahale gerekli |
| <50% | BASARISIZ | Acil mudahale, sistem guvenilmez |

---

## Rapor Uretimi

Sonuclari `tests/results/scorecards/YYYY-MM-DD.md` dosyasina yaz:

```markdown
# Governance Denetim Raporu — {tarih}

## Ozet
Genel Skor: %{skor} — {SAGLAM/YETERLI/ZAYIF/BASARISIZ}
Onceki Skor: %{onceki_skor} ({onceki_tarih})
Degisim: {+/-} {fark} puan

## Katman 1: Yapisal Kontrol ({gecen}/{toplam})
- [PASS/FAIL] {kontrol adi} — {detay}
...

## Katman 2: Icerik Tutarliligi ({gecen}/{toplam})
- [PASS/FAIL/PARTIAL] {kontrol adi} — {detay}
...

## Katman 3: Davranissal Test ({gecen}/{toplam})
Her senaryo icin:
- Bulgu: "{katman 1-2 bulgusu}"
- Tuzak: {ne uretildi, kisa aciklama}
- Agent: {hangi agent}
- Sonuc: {PASS/PARTIAL/FAIL} — {agent ne buldu, ne kacirdi}
...

## Trend
| Tarih | Skor | Durum | Not |
|-------|------|-------|-----|
| ... | ... | ... | ... |

## Oneriler
{Bulgulara dayali somut iyilestirme onerileri}
```

---

## Trend Takibi

Her calistirmada `tests/results/trends.md` dosyasini guncelle:

```markdown
# Governance Denetim Trend Takibi

| Tarih | Genel Skor | K1 (Yapisal) | K2 (Tutarlilik) | K3 (Davranissal) | Durum | Not |
|-------|------------|--------------|-----------------|-------------------|-------|-----|
| ... | ... | ... | ... | ... | ... | ... |
```

Ilk calistirma → ayni zamanda `tests/results/baseline.md` olarak da kaydet.

---

## Calistirma Kurallari

1. Katmanlar SIRAYLA calisir (1 → 2 → 3). Cunku 3, onceki bulgulara dayanir.
2. Her katmanin sonucu context'te tutulur, bir sonrakine aktarilir.
3. Rapor tum katmanlar bittikten sonra yazilir.
4. Onceki scorecard varsa trend karsilastirmasi yapilir.
5. Kullanici mudahalesi GEREKMEZ — Team Lead tum sureci yonetir.
