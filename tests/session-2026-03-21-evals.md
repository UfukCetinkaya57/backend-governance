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
