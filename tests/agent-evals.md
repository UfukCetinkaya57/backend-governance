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
