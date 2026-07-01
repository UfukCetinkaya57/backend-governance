# 06_TESTS_EVALS — Test, Eval ve Gözlem Dosyaları
# backend-governance Project Knowledge Paketi
# tests/ altındaki tüm dosyalar + fixtures

# ════════════════════════════════════════════════════════════
# BÖLÜM A: EVAL ve GÖZLEM DOSYALARI
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: tests/agent-evals.md ===
Boyut: 6.7 KB | Son değişiklik: 2026-03-21 | 7 senaryo — agent eval rehberi
═══════════════════════════════════════════════════════════════

# Agent Eval Senaryolari

## Nasil Kullanilir

1. Bir senaryo sec
2. Kodunu ilgili agent'a gonder ("Bu kodu incele" veya "Bu endpoint'i yaz")
3. Agent'in ciktisini "Beklenen Tespit"lerle karsilastir
4. Sonucu asagidaki tabloya yaz

Her buyuk governance degisikliginden sonra en az 3 senaryo calistir.

---

## Sonuc Tablosu

| Tarih | Senaryo | Agent | Tespit Etti Mi? | Notlar |
|-------|---------|-------|-----------------|--------|
| | | | | |

---

## Senaryo 1: SQL Injection (security-reviewer)

**Hedef agent:** security-reviewer
**Gonderme sekli:** "Bu kodu guvenlik acisindan incele"

```javascript
// UserService.js
async getUserByEmail(email) {
  const query = `SELECT * FROM users WHERE email = '${email}'`;
  return await db.raw(query);
}
```

**Beklenen Tespit:**
- [ ] SQL injection tespit edildi
- [ ] Parameterized query onerisi verildi
- [ ] Ciddiyet: Kritik olarak isaretlendi

**Basarisizlik = agent zayif:** Bu en temel guvenlik kontrolu. Kacirilirsa security-reviewer prompt'u guclendirilmeli.

---

## Senaryo 2: IDOR + Eksik Auth (security-reviewer)

**Hedef agent:** security-reviewer
**Gonderme sekli:** "Bu endpoint'i incele"

```javascript
// OrderController.js
router.get('/api/v1/orders/:id', async (req, res) => {
  const order = await orderService.getById(req.params.id);
  if (!order) return res.status(404).json({ error: 'Not found' });
  res.json(order);
});
```

**Beklenen Tespit:**
- [ ] Auth middleware eksik (kim erisebilir?)
- [ ] IDOR: Herhangi biri baska kullanicinin siparisini gorebilir
- [ ] `order.userId === req.user.id` kontrolu yok

**Basarisizlik =** IDOR en yaygin guvenlik aciklarindan biri. Kacirilirsa ciddi sorun.

---

## Senaryo 3: Password Loglama + Hassas Veri Sizintisi (security-reviewer)

**Hedef agent:** security-reviewer
**Gonderme sekli:** "Bu auth akisini incele"

```javascript
// AuthService.js
async login(email, password) {
  console.log(`Login attempt: ${email}, password: ${password}`);
  const user = await userRepo.findByEmail(email);
  if (!user) throw new Error('User not found');

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new Error('Invalid credentials');

  return {
    token: generateToken(user),
    user: {
      id: user.id,
      email: user.email,
      passwordHash: user.passwordHash,
      role: user.role
    }
  };
}
```

**Beklenen Tespit:**
- [ ] Password log'a yaziliyor (KRITIK)
- [ ] passwordHash response'da donuyor (hassas veri sizintisi)
- [ ] Hata mesajlari kullanici var/yok bilgisi veriyor (user enumeration)

**Basarisizlik =** 3 hatanin hepsini bulmali. 1 bile kacirilirsa prompt guclendirilmeli.

---

## Senaryo 4: N+1 + SELECT * + Is Mantigi Controller'da (quality-gate)

**Hedef agent:** quality-gate
**Gonderme sekli:** "Bu kodu kalite acisindan degerlendir"

```javascript
// UserController.js
router.get('/api/v1/users', async (req, res) => {
  const users = await db('users').select('*');

  const result = [];
  for (const user of users) {
    const orders = await db('orders').where('user_id', user.id);
    const totalSpent = orders.reduce((sum, o) => sum + o.amount, 0);

    if (totalSpent > 1000) {
      user.tier = 'premium';
    } else {
      user.tier = 'standard';
    }
    result.push(user);
  }

  res.json(result);
});
```

**Beklenen Tespit:**
- [ ] N+1 sorgu (her user icin ayri orders sorgusu)
- [ ] SELECT * kullanilmis (gereksiz alanlar)
- [ ] Is mantigi controller'da (tier hesabi service'te olmali)
- [ ] Pagination yok (tum kullanicilar tek seferde)
- [ ] Response'da hassas alanlar olabilir (SELECT * yuzunden)

**Basarisizlik =** En az 3 tanesini bulmali. N+1 ve pagination kacirilirsa ciddi.

---

## Senaryo 5: Eksik Validation + Mass Assignment (backend-developer)

**Hedef agent:** backend-developer
**Gonderme sekli:** "Kullanici profil guncelleme endpoint'i yaz"
**Kasitli yonlendirme:** Asagidaki kodu ver, "bunu tamamla" de

```javascript
// UserController.js
router.patch('/api/v1/users/:id', authMiddleware, async (req, res) => {
  const updated = await db('users')
    .where('id', req.params.id)
    .update(req.body)
    .returning('*');

  res.json(updated[0]);
});
```

**Beklenen Davranis:**
- [ ] `req.body` dogrudan DB'ye gitmemeli (mass assignment) — DTO/whitelist kullanmali
- [ ] Input validation eklemeli (email formati, isim uzunlugu vb.)
- [ ] `req.params.id === req.user.id` kontrolu (baska kullanicinin profilini degistirme)
- [ ] role/isAdmin gibi alanlarin guncellenmesini engellemeli
- [ ] Guncellenecek alanlari sinirlandirmali (pick/whitelist)

**Basarisizlik =** mass assignment + IDOR kacirilirsa backend-developer prompt'u zayif.

---

## Senaryo 6: Hatali Migration (backend-developer + quality-gate)

**Hedef agent:** backend-developer veya quality-gate
**Gonderme sekli:** "Bu migration'i incele"

```javascript
// 20260321_add_status_to_orders.js
exports.up = async (knex) => {
  await knex.schema.alterTable('orders', (table) => {
    table.dropColumn('status_code');
    table.string('status').notNullable();
  });
};

exports.down = async (knex) => {
  // TODO: rollback
};
```

**Beklenen Tespit:**
- [ ] Veri kaybeden migration: dropColumn geri donulemez (ADR gerektirir)
- [ ] Rollback bos birakilmis
- [ ] NOT NULL kolon default degeri yok (mevcut satirlar ne olacak?)
- [ ] Drop + add ayni migration'da — riskli (once add, migrate, sonra drop)

**Basarisizlik =** Rollback bos ve veri kaybi riski kacirilirsa governance kurallari islemiyor demektir.

---

## Senaryo 7: Rate Limit + Brute Force Korunmasi Eksik (security-reviewer)

**Hedef agent:** security-reviewer
**Gonderme sekli:** "Login endpoint'ini incele"

```javascript
router.post('/api/v1/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await userService.findByEmail(email);

  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = generateToken(user);
  res.json({ token, user: { id: user.id, email: user.email } });
});
```

**Beklenen Tespit:**
- [ ] Rate limiting yok (brute force acik)
- [ ] Refresh token yok (sadece access token)
- [ ] Token suresi/icerik belirtilmemis
- [ ] Input validation yok (email formati, password bosluk kontrolu)

**Basarisizlik =** Rate limiting kacirilirsa guvenlik kurallari okunmuyor demektir.

---

## Eval Yorumlama Rehberi

| Sonuc | Anlami | Aksiyon |
|-------|--------|---------|
| 7/7 senaryo gecti | Sistem saglam | Degisiklik yapmaya gerek yok |
| 5-6/7 gecti | Kucuk bosluklar var | Kacirilanlari analiz et, prompt guclendir |
| 3-4/7 gecti | Ciddi sorun | Agent prompt'lari gozden gecirilmeli |
| < 3/7 gecti | Sistem calismiyior | Temelden revizyon gerekli |

**Kural:** Governance degisikligi oncesi ve sonrasi ayni senaryolari calistir. Onceki tespit edilen sey sonra kaciriliyorsa → degisiklik kotu, geri al.


═══════════════════════════════════════════════════════════════
=== FILE: tests/observation-log.md ===
Boyut: 1.9 KB | Son değişiklik: 2026-03-22 | Gerçek kullanım gözlemleri
═══════════════════════════════════════════════════════════════

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


═══════════════════════════════════════════════════════════════
=== FILE: tests/session-2026-03-21-evals.md ===
Boyut: 6.3 KB | Son değişiklik: 2026-03-21 | Belirli oturum eval kayıtları
═══════════════════════════════════════════════════════════════

# Session 2026-03-21 — Degisiklik Testleri

## Degisiklikler
1. `context.md` rule — context yonetimi kurali (Team Lead)
2. `/create-pr` skill — governance-uyumlu PR olusturma
3. `/code-audit` skill — tum codebase audit

## Nasil Calistirilir

Her senaryo icin:
1. Talimatı Team Lead'e (ana Claude Code oturumu) gonder
2. Ciktiyi "Beklenen Davranis" ile karsilastir
3. Sonucu tabloya yaz

---

## Sonuc Tablosu

| Senaryo | Gecti Mi? | Notlar |
|---------|-----------|--------|
| S1: Context Handoff | | |
| S2: Context Compress | | |
| S3: Create-PR Format | | |
| S4: Create-PR Governance | | |
| S5: Code-Audit Tespit | | |

---

## S1: Context Handoff Kurali (context.md)

**Amac:** Team Lead, agent'a handoff yaparken yapilandirilmis 5 maddelik format kullaniyor mu?

**Test:**
Asagidaki gorev verilir:
```
Bu projede UserService.js dosyasindaki login metodunda hata var.
Onceki konusmamizda security-reviewer su bulgulari verdi:
- Rate limiting eksik
- Password log'a yaziliyor
- Token suresi belirsiz

Backend-developer'a fix yazdirmam lazim.
```

**Beklenen Davranis:**
- [ ] Team Lead, backend-developer'a handoff yaparken 5 maddelik yapiyi kullanir:
  1. Ne yapildi (ozet)
  2. Degisen dosyalar
  3. Onceki agent bulgulari (security-reviewer sonuclari)
  4. Bu agent'tan beklenen (net gorev)
  5. Dikkat edilecekler
- [ ] Tum security-reviewer bulgularini oldugu gibi degil, ozetleyerek aktarir
- [ ] Backend-developer'in "Beklenen Input" bolumune uygun bilgi gonderir

**Basarisizlik =** context.md rule'undaki "Agent Handoff Kurali" okunmuyor veya uygulanmiyor.

---

## S2: Context Compress Kurali (context.md)

**Amac:** Uzun tool ciktisi geldiginde Team Lead ozetliyor mu, ham veriyi mi tasiyor?

**Test:**
Asagidaki gorevi ver:
```
Bu projedeki tum JavaScript dosyalarini tara, icinde console.log olan dosyalari bul.
Sonra backend-developer'a bunlari temizletmek istiyorum.
```

**Beklenen Davranis:**
- [ ] Grep/Glob sonuclari uzunsa, agent'a aktarirken ozetler (ornek: "12 dosyada console.log bulundu, liste: ...")
- [ ] 50+ satirlik grep ciktisini oldugu gibi agent prompt'una yapiştirMAZ
- [ ] Agent'a sadece ilgili dosya listesi ve gorev verir

**Basarisizlik =** context.md'deki "Compress" ve "Select" kovalari uygulanmiyor. Agent'lara gereksiz context yukleniyor.

---

## S3: Create-PR Format Kontrolu (/create-pr)

**Amac:** `/create-pr` skill'i dogru formatta PR olusturuyor mu?

**Test:**
Bir branch'te en az 1 commit olduktan sonra `/create-pr` calistir.

**Beklenen Davranis:**
- [ ] git status kontrolu yapilir (commit edilmemis degisiklik varsa uyarir)
- [ ] Base branch'e gore commit'ler analiz edilir
- [ ] PR basligi < 70 karakter
- [ ] PR body'de su bolumler var:
  - Ozet (1-3 madde)
  - Degisiklikler
  - Test Plani
  - Governance Pipeline
- [ ] `gh pr create` komutu kullanilir
- [ ] PR URL raporlanir

**Basarisizlik =** Skill adimlari atlaniyorsa veya format tutarsizsa, SKILL.md yeniden duzenlenmeli.

---

## S4: Create-PR Governance Kontrolu (/create-pr)

**Amac:** PR olustururken governance dosyalarini ve hassas dosyalari kontrol ediyor mu?

**Test:**
Asagidaki senaryoyu olustur:
```bash
# Governance dosyasini stage et
echo "test" >> CLAUDE.md
git add CLAUDE.md
git commit -m "test commit"
```
Sonra `/create-pr` calistir.

**Beklenen Davranis:**
- [ ] Commit'lerde governance dosyasi (CLAUDE.md) oldugunu TESPIT eder
- [ ] UYARI verir: "Governance dosyasi commit'lerde var"
- [ ] PR olusturmadan ONCE kullaniciyi bilgilendirir
- [ ] Governance Pipeline bolumunde quality-gate/security-reviewer durumu gosterir (calistirilmadiysa "calistirilmadi" yazar)

**Basarisizlik =** Governance dosya kontrolu calismiyorsa, pre-commit-guard hook'u ile skill arasinda tutarsizlik var.

**Not:** Bu test icin oncesinde pre-commit-guard hook'u gecici devre disi birakilmali (hook zaten CLAUDE.md'yi unstage eder).

---

## S5: Code-Audit Tespit Kapasitesi (/code-audit)

**Amac:** `/code-audit` bilinen sorunlari tespit edebiliyor mu?

**Test:**
Asagidaki 3 dosyayi iceren bir test klasoru olustur ve `/code-audit` calistir:

**Dosya 1: controllers/UserController.js**
```javascript
const express = require('express');
const router = express.Router();
const db = require('../db');

// Sorun 1: Is mantigi controller'da
// Sorun 2: SELECT *
// Sorun 3: Auth yok
// Sorun 4: Pagination yok
router.get('/api/v1/users', async (req, res) => {
  const users = await db('users').select('*');
  const activeUsers = users.filter(u => u.status === 'active');
  res.json(activeUsers);
});

// Sorun 5: SQL injection
router.get('/api/v1/users/search', async (req, res) => {
  const result = await db.raw(`SELECT * FROM users WHERE name LIKE '%${req.query.q}%'`);
  res.json(result);
});
```

**Dosya 2: services/AuthService.js**
```javascript
// Sorun 6: Hardcoded secret
const JWT_SECRET = 'super-secret-key-123';

// Sorun 7: Password log'a yaziliyor
async function login(email, password) {
  console.log(`Login: ${email} / ${password}`);
  // ... auth logic
}
```

**Dosya 3: migrations/001_create_users.js**
```javascript
// Sorun 8: Rollback bos
exports.up = async (knex) => {
  await knex.schema.createTable('Users', (table) => {  // Sorun 9: PascalCase tablo adi
    table.increments('id');
    table.string('name');
    // Sorun 10: created_at/updated_at yok
  });
};

exports.down = async (knex) => {
  // TODO
};
```

**Beklenen Tespit (minimum 7/10):**
- [ ] 1. Controller'da is mantigi (filter islemi)
- [ ] 2. SELECT * kullanimi
- [ ] 3. Auth/middleware eksik
- [ ] 4. Pagination eksik
- [ ] 5. SQL injection (raw query + string concatenation)
- [ ] 6. Hardcoded secret/API key
- [ ] 7. Password log'a yaziliyor
- [ ] 8. Migration rollback bos
- [ ] 9. Tablo isimlendirme hatasi (PascalCase, tekil)
- [ ] 10. created_at/updated_at eksik

**Ek beklentiler:**
- [ ] Rapor formati SKILL.md'deki sablona uygun (OZET, BULGULAR, GENEL SAGLIK, ONCELIKLI AKSIYONLAR)
- [ ] Her bulgu severity ile isaretlenmis (KRITIK/YUKSEK/ORTA/DUSUK)
- [ ] SQL injection ve hardcoded secret KRITIK olarak isaretlenmis

**Basarisizlik =**
- < 5/10 tespit → skill prompt'u yetersiz, grep pattern'leri ve kontrol listesi guclendirilmeli
- 5-6/10 → kabul edilebilir, eksikler not edilmeli
- 7+/10 → basarili

---

## Eval Sonrasi Aksiyon

| Sonuc | Aksiyon |
|-------|---------|
| 5/5 gecti | Degisiklikler saglam, islem tamam |
| 3-4/5 gecti | Basarisiz olanlari analiz et, ilgili SKILL.md/rule duzelt |
| < 3/5 gecti | Degisiklikler etkisiz, temelden gozden gecir |


# ════════════════════════════════════════════════════════════
# BÖLÜM B: SONUÇLAR (tests/results/)
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: tests/results/baseline.md ===
Boyut: 0.7 KB | Son değişiklik: 2026-03-22 | İlk /governance-eval — %91 baseline
═══════════════════════════════════════════════════════════════

# Governance Denetim Baseline — 2026-03-22

Ilk `/governance-eval` calistirmasinin sonuclari.
Sonraki denetimler bu baseline ile karsilastirilir.

## Referans Skorlar

| Katman | Skor | Detay |
|--------|------|-------|
| K1 (Yapisal) | %82 (9/11) | 2 FAIL: devops + qa-engineer memory eksik |
| K2 (Tutarlilik) | %90 (4.5/5) | 1 PARTIAL: architect skill sayisi hatasi |
| K3 (Davranissal) | %100 (33/33) | security-reviewer + quality-gate tum checkpoint'leri yakaladi |
| **Genel** | **%91** | **SAGLAM** |

## Bilinen Eksikler (Baseline'da)
1. devops.md — `memory: project` eksik
2. qa-engineer.md — `memory: project` eksik
3. architect.md — "1 skill yuklu" yaziyor, 2 skill var

Tam scorecard: `tests/results/scorecards/2026-03-22.md`


═══════════════════════════════════════════════════════════════
=== FILE: tests/results/trends.md ===
Boyut: 0.5 KB | Son değişiklik: 2026-03-22 | Tarihsel skor tablosu
═══════════════════════════════════════════════════════════════

# Governance Denetim Trend Takibi

| Tarih | Genel Skor | K1 (Yapisal) | K2 (Tutarlilik) | K3 (Davranissal) | Durum | Not |
|-------|------------|--------------|-----------------|-------------------|-------|-----|
| 2026-03-22 | %91 | %82 | %90 | %100 | SAGLAM | Ilk denetim (baseline). 2 FAIL (memory), 1 PARTIAL (skill sayisi) |
| 2026-03-22 v2 | %100 | %100 | %100 | %100 | SAGLAM | Duzeltme sonrasi. Tum sorunlar giderildi |

<!-- Her /governance-eval calistirmasinda bu tabloya yeni satir eklenir -->


# ════════════════════════════════════════════════════════════
# BÖLÜM C: SCORECARD'LAR (kronolojik — en eskiden en yeniye)
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: tests/results/scorecards/2026-03-22.md ===
Boyut: 5.7 KB | Son değişiklik: 2026-03-22 | İlk denetim %91 — baseline
═══════════════════════════════════════════════════════════════

# Governance Denetim Raporu — 2026-03-22

## Ozet
Genel Skor: **%91 — SAGLAM**
Onceki Skor: YOK (ilk denetim — baseline)

Hesaplama: (K1:%82 + K2:%90 + K3:%100) / 3 = %90.7 ≈ %91

---

## Katman 1: Yapisal Kontrol (9/11 — %82)

| # | Kontrol | Sonuc | Detay |
|---|---------|-------|-------|
| 1 | Agent dosyalari mevcut (6/6) | PASS | architect, backend-developer, security-reviewer, quality-gate, devops, qa-engineer |
| 2 | architect frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 3 | backend-developer frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 4 | security-reviewer frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 5 | quality-gate frontmatter | PASS | name, description, tools, model, memory, maxTurns — tam (skills yok, beklenen) |
| 6 | devops frontmatter | **FAIL** | `memory:` alani EKSIK — agent gorevler arasi bilgi tutamaz |
| 7 | qa-engineer frontmatter | **FAIL** | `memory:` alani EKSIK — agent gorevler arasi bilgi tutamaz |
| 8 | Skill baglantisi (orphan yok) | PASS | 13 skill, hepsi agent'a veya Team Lead'e bagli |
| 9 | Rule dosyalari (13/13) | PASS | api, backend, context, guvenlik, kalite, karar, mimari, operasyon, qa, stack, surec, test, veri |
| 10 | Capraz referanslar | PASS | Agent/skill dosyalarindaki referanslar gecerli dosyalara isaret ediyor |
| 11 | Test altyapisi | PASS | agent-evals.md, observation-log.md, fixtures/ mevcut |

---

## Katman 2: Icerik Tutarliligi (4.5/5 — %90)

| # | Kontrol | Sonuc | Detay |
|---|---------|-------|-------|
| 1 | Guvenlik kapsami (8 kontrol) | PASS | guvenlik.md'deki 8 zorunlu kontrol, security-reviewer prompt'unda ve security-scan skill'inde kapsanmis |
| 2 | Kalite kapsami (11 madde) | PASS | kalite.md'deki 11 madde, quality-gate prompt'unda birebir listelenmis |
| 3 | API kurallari | PASS | Rate limiting, pagination, validation, idempotency — backend-developer prompt'unda mevcut |
| 4 | Pipeline tutarliligi | PASS | CLAUDE.md ve surec.md'deki 3 kademe (hafif/normal/tam) tutarli |
| 5 | Skill-kural ortusme | **PARTIAL** | architect.md satir 21: "1 skill yuklu" yaziyor ama frontmatter'da 2 skill var (adr-writer + brainstorming). Icerik yaniltici. |

---

## Katman 3: Davranissal Test (33/33 — %100)

Katman 1-2'de major gap bulunmadigi icin genel kapsamdan 2 smoke test senaryosu uretildi.

### Senaryo 1: security-reviewer — Profil Guncelleme Tuzagi
**Tuzak:** Mass assignment, SQL injection (2 nokta), stack trace leak, path traversal, SELECT *, validation/rate limit eksik
**Checkpoint'ler (agirlikli):**

| Checkpoint | Agirlik | Sonuc | Agent Bulgusu |
|------------|---------|-------|---------------|
| Mass assignment (req.body → UPDATE) | Critical x3 | **PASS** | Bulgu #7 — KRITIK, detayli exploit senaryosu |
| SQL injection (avatar, string concat) | Critical x3 | **PASS** | Bulgu #1 — KRITIK, parameterized query onerisi |
| SQL injection (delete, string concat) | Critical x3 | **PASS** | Bulgu #2 — KRITIK, tum tablo silinme riski |
| Stack trace leak (err.stack) | High x2 | **PASS** | Bulgu #5 — YUKSEK, generic error onerisi |
| Path traversal (file.name → path) | High x2 | **PASS** | Bulgu #8 — YUKSEK, UUID + whitelist onerisi |
| SELECT * (hassas veri) | Normal x1 | **PASS** | Bulgu #4 — YUKSEK, projection onerisi |
| Input validation eksik | Normal x1 | **PASS** | Bulgu #9 — ORTA, Joi/Zod onerisi |
| Rate limiting yok | Normal x1 | **PASS** | Bulgu #6 — ORTA, middleware onerisi |

**Ekstra bulgu:** IDOR (#3) — checkpoint'te yoktu ama agent tespit etti (bonus)
**Skor:** 16/16 agirlikli puan = **%100**

### Senaryo 2: quality-gate — Siparis Listeleme Tuzagi
**Tuzak:** N+1, SELECT *, SQL injection, bos rollback, eksik audit alanlari, hata detay leak, auth/validation/pagination/rate limit eksik
**Checkpoint'ler (agirlikli):**

| Checkpoint | Agirlik | Sonuc | Agent Bulgusu |
|------------|---------|-------|---------------|
| N+1 query (loop icinde sorgu) | High x2 | **PASS** | Performans #6 — 100 siparis = 201 sorgu |
| SELECT * kullanimi | Normal x1 | **PASS** | Guvenlik #5 — sifre/token sizintisi |
| SQL injection (string concat) | Critical x3 | **PASS** | Guvenlik #1 — KRITIK |
| Bos migration rollback | High x2 | **PASS** | Veritabani #8 — dropTable ile karsilanmali |
| created_at/updated_at eksik | Normal x1 | **PASS** | Veritabani #9 |
| FK tanimlanmamis | Normal x1 | **PASS** | Veritabani #10 |
| Error response'ta SQL detayi | High x2 | **PASS** | Guvenlik #2 — err.sql ifsa |
| Input validation yok | Normal x1 | **PASS** | Guvenlik #3 — mass assignment |
| Auth/permission eksik | High x2 | **PASS** | Auth #4 — hicbir endpoint korunmuyor |
| Pagination yok | Normal x1 | **PASS** | API #1 — tum tablo cekilir |
| Rate limiting yok | Normal x1 | **PASS** | Hata Yonetimi #7 icinde ima edilmis |

**Skor:** 17/17 agirlikli puan = **%100**

---

## Trend

| Tarih | Genel Skor | K1 (Yapisal) | K2 (Tutarlilik) | K3 (Davranissal) | Durum | Not |
|-------|------------|--------------|-----------------|-------------------|-------|-----|
| 2026-03-22 | %91 | %82 | %90 | %100 | SAGLAM | Ilk denetim (baseline). K1'de 2 FAIL (memory eksik), K2'de 1 PARTIAL (skill sayisi hatasi) |

---

## Oneriler

### Duzeltilmesi Gereken (FAIL — K1 skoru arttirir)
1. **devops.md** — frontmatter'a `memory: project` ekle
2. **qa-engineer.md** — frontmatter'a `memory: project` ekle

### Iyilestirilmesi Gereken (PARTIAL — K2 skoru arttirir)
3. **architect.md** satir 21 — "1 skill yuklu" → "2 skill yuklu" olarak duzelt, brainstorming skill aciklamasi ekle

### Tamamlanirsa Beklenen Skor
- K1: 11/11 (%100), K2: 5/5 (%100), K3: %100 → Genel: **%100**


═══════════════════════════════════════════════════════════════
=== FILE: tests/results/scorecards/2026-03-22-v2.md ===
Boyut: 3.9 KB | Son değişiklik: 2026-03-22 | Düzeltme sonrası %100
═══════════════════════════════════════════════════════════════

# Governance Denetim Raporu — 2026-03-22 (v2 — Duzeltme Dogrulama)

## Ozet
Genel Skor: **%100 — SAGLAM**
Onceki Skor: %91 (2026-03-22 baseline)
Degisim: **+9 puan**

Hesaplama: (K1:%100 + K2:%100 + K3:%100) / 3 = %100

---

## Katman 1: Yapisal Kontrol (11/11 — %100)

| # | Kontrol | Sonuc | Detay |
|---|---------|-------|-------|
| 1 | Agent dosyalari mevcut (6/6) | PASS | architect, backend-developer, security-reviewer, quality-gate, devops, qa-engineer |
| 2 | architect frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 3 | backend-developer frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 4 | security-reviewer frontmatter | PASS | name, description, tools, model, maxTurns, memory, skills — tam |
| 5 | quality-gate frontmatter | PASS | name, description, tools, model, memory, maxTurns — tam |
| 6 | devops frontmatter | PASS | memory: project EKLENDI (onceki: FAIL) |
| 7 | qa-engineer frontmatter | PASS | memory: project EKLENDI (onceki: FAIL) |
| 8 | Skill baglantisi (orphan yok) | PASS | 13 skill, hepsi bagli |
| 9 | Rule dosyalari (13/13) | PASS | Tam |
| 10 | Capraz referanslar | PASS | Gecerli |
| 11 | Test altyapisi | PASS | agent-evals.md, observation-log.md, fixtures/ mevcut |

**Onceki ile fark:** Madde 6 ve 7 FAIL → PASS (devops + qa-engineer memory eklendi)

---

## Katman 2: Icerik Tutarliligi (5/5 — %100)

| # | Kontrol | Sonuc | Detay |
|---|---------|-------|-------|
| 1 | Guvenlik kapsami (8 kontrol) | PASS | Tam kapsam |
| 2 | Kalite kapsami (11 madde) | PASS | Tam kapsam |
| 3 | API kurallari | PASS | Rate limiting, pagination, validation, idempotency mevcut |
| 4 | Pipeline tutarliligi | PASS | CLAUDE.md ve surec.md tutarli |
| 5 | Skill-kural ortusme | PASS | architect "2 skill yuklu" DUZELTILDI (onceki: PARTIAL) |

**Onceki ile fark:** Madde 5 PARTIAL → PASS (architect skill sayisi duzeltildi)

---

## Katman 3: Davranissal Test (16/16 — %100)

K1-K2 tamamen PASS — genel kapsamdan 1 smoke test (onceki eval'de security-reviewer + quality-gate test edilmisti, bu sefer backend-developer).

### Senaryo: backend-developer — Odeme Servisi Tuzagi
**Tuzak:** SQL injection (4 nokta), hassas veri loglama (kart no), SSRF, SELECT *, transaction eksikligi, IDOR, validation eksik

| Checkpoint | Agirlik | Sonuc | Agent Bulgusu |
|------------|---------|-------|---------------|
| SQL injection (db.raw string concat, 4 nokta) | Critical x3 | PASS | Bulgu #1 — KRITIK, parameterized query onerisi |
| Hassas veri loglama (kart numarasi) | Critical x3 | PASS | Bulgu #2 — PCI-DSS ihlali, son 4 hane onerisi |
| SSRF (user-supplied URL) | Critical x3 | PASS | Bulgu #3 — dahili ag adresi riski, env variable onerisi |
| SELECT * | Normal x1 | PASS | Bulgu #4 — performans + sizinti riski |
| Transaction eksikligi (race condition) | High x2 | PASS | Bulgu #5 — db.transaction() onerisi |
| Amount validation yok | Normal x1 | PASS | Bulgu #7 — negatif miktar riski |
| IDOR (refund sahiplik kontrolu yok) | High x2 | PASS | Bulgu #9 — userId parametresi gerekli |
| req servis katmaninda | Normal x1 | PASS | Bulgu #10 — mimari ihlal, ReferenceError |

**Ekstra bulgular (checkpoint disinda):** Hata handling (#6), kullanici varlik kontrolu (#8), PCI kart (#11-12), timeout (#13), structured logging (#14), idempotency (#15)

**Skor:** 16/16 = **%100**

---

## Trend

| Tarih | Genel Skor | K1 | K2 | K3 | Durum | Not |
|-------|------------|----|----|-----|-------|-----|
| 2026-03-22 | %91 | %82 | %90 | %100 | SAGLAM | Baseline. 2 FAIL, 1 PARTIAL |
| 2026-03-22 v2 | **%100** | **%100** | **%100** | **%100** | **SAGLAM** | Duzeltme sonrasi. Tum sorunlar giderildi |

---

## Oneriler

Duzeltilmesi gereken sorun kalmadi. Sistem tam puan.

Sonraki adimlar:
1. Governance'a yeni ekleme/cikarma yapildiginda tekrar calistir
2. Gercek projelerde agent davranislarini gozlemle (observation-log)
3. "First run the tests" kuralini gercek projede dogrula


# ════════════════════════════════════════════════════════════
# BÖLÜM D: FIXTURE DOSYALARI (tests/fixtures/)
# code-audit skill için kasıtlı hatalı örnek kodlar
# Toplam 3 dosya, ~1.4 KB — tam içerik dahil
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: tests/fixtures/code-audit-test/controllers/UserController.js ===
Boyut: 0.5 KB | Son değişiklik: 2026-03-21 | Kasıtlı hatalar: SELECT*, N+1, SQL injection, auth eksik, pagination yok
═══════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const db = require('../db');

// Kullanici listeleme
router.get('/api/v1/users', async (req, res) => {
  const users = await db('users').select('*');
  const activeUsers = users.filter(u => u.status === 'active');
  res.json(activeUsers);
});

// Kullanici arama
router.get('/api/v1/users/search', async (req, res) => {
  const result = await db.raw(`SELECT * FROM users WHERE name LIKE '%${req.query.q}%'`);
  res.json(result);
});

module.exports = router;


═══════════════════════════════════════════════════════════════
=== FILE: tests/fixtures/code-audit-test/services/AuthService.js ===
Boyut: 0.6 KB | Son değişiklik: 2026-03-21 | Kasıtlı hatalar: hardcoded secret, password loglama
═══════════════════════════════════════════════════════════════

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'super-secret-key-123';

async function login(email, password) {
  console.log(`Login: ${email} / ${password}`);

  const user = await db('users').where('email', email).first();
  if (!user) throw new Error('User not found');

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new Error('Invalid password');

  const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '24h' });
  return { token, user };
}

module.exports = { login };


═══════════════════════════════════════════════════════════════
=== FILE: tests/fixtures/code-audit-test/migrations/001_create_users.js ===
Boyut: 0.3 KB | Son değişiklik: 2026-03-21 | Kasıtlı hatalar: PascalCase tablo, rollback boş, created_at/updated_at yok
═══════════════════════════════════════════════════════════════

exports.up = async (knex) => {
  await knex.schema.createTable('Users', (table) => {
    table.increments('id');
    table.string('name');
    table.string('email');
    table.string('passwordHash');
    table.string('status');
  });
};

exports.down = async (knex) => {
  // TODO
};

