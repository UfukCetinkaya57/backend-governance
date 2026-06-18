---
name: tdd
description: Feature veya bugfix implementasyonunda, uygulama kodu yazmadan ONCE kullan
---

# Test-Driven Development (TDD)

## Temel Kural

```
FAILING TEST OLMADAN UYGULAMA KODU YAZILMAZ. ISTISNASI YOK.
```

Test'ten once kod yazdiysan → sil, bastan basla.

## Ne Zaman Kullanilir

**Her zaman:**
- Yeni feature
- Bug fix
- Refactoring
- Davranis degisikligi

**Istisnalar (kullaniciya sor):**
- Bir kerelik prototip
- Generate edilen kod
- Config dosyalari

## Red-Green-Refactor Dongusu

### RED — Failing Test Yaz

Tek bir davranisi gosteren minimal test yaz.

```typescript
// IYI: Net isim, gercek davranisi test eder
test('should return 404 when user does not exist', async () => {
  const res = await request(app).get('/api/v1/users/999');
  expect(res.status).toBe(404);
  expect(res.body.error.code).toBe('NOT_FOUND');
});
```

```typescript
// KOTU: Belirsiz isim, mock test eder
test('user test', async () => {
  const mock = jest.fn().mockResolvedValue(null);
  expect(mock).toHaveBeenCalled();
});
```

Kurallar:
- Tek davranis
- Acik isim (ne test ettigini soyle)
- Gercek kod test et (mock sadece kacinilmazsa)

### RED DOGRULA — Hata Verdigini Gor

```bash
npm test path/to/test.test.ts
```

- Test FAIL ediyor mu? (error degil, FAIL)
- Hata mesaji beklenen mi?
- Feature eksik oldugu icin mi fail ediyor (typo degil)?

Test PASS ediyorsa → mevcut davranisi test ediyorsun, test'i duzelt.

### GREEN — Minimal Kod Yaz

Test'i gecirmek icin EN BASIT kodu yaz.

```typescript
// IYI: Yeterli kadar
async function getUserById(id: string) {
  const user = await db('users').where('id', id).first();
  if (!user) throw new NotFoundError('User not found');
  return user;
}
```

```typescript
// KOTU: Over-engineered
async function getUserById(
  id: string,
  options?: { cache?: boolean; include?: string[]; transform?: (u: User) => any }
) { /* YAGNI */ }
```

Feature ekleme, baska kodu refactor etme, test'in otesinde "iyilestirme" yapma.

### GREEN DOGRULA — Gectigini Gor

```bash
npm test path/to/test.test.ts
```

- Test PASS ediyor mu?
- Diger testler hala geciyor mu?
- Ciktida hata/uyari yok mu?

### REFACTOR — Temizle

Sadece GREEN'den sonra:
- Tekrari kaldir
- Isimleri iyilestir
- Helper'lar cikar

Testler yesil kalsin. Yeni davranis EKLEME.

### Tekrarla

Siradaki davranis icin yeni failing test yaz.

## Bug Fix Ornegi

**Bug:** Bos email kabul ediliyor

**RED:**
```typescript
test('should reject empty email with validation error', async () => {
  const res = await request(app)
    .post('/api/v1/auth/register')
    .send({ email: '', password: 'Test1234!' });
  expect(res.status).toBe(422);
  expect(res.body.error.code).toBe('VALIDATION_ERROR');
});
```

**RED DOGRULA:** FAIL — expected 422, got 201 ✓

**GREEN:**
```typescript
if (!data.email?.trim()) {
  throw new ValidationError('Email zorunludur');
}
```

**GREEN DOGRULA:** PASS ✓

**REFACTOR:** Baska alanlar icin de validation gerekiyorsa cikar.

## Yaygin Bahaneler

| Bahane | Gercek |
|--------|--------|
| "Test yazacak kadar basit degil" | Basit kod da kirilir. Test 30 saniye surer. |
| "Sonra test yazarim" | Hemen gecen test hicbir sey kanitlamaz. |
| "Once elle test ettim" | Elle test sistematik degil, tekrar calistirilamaz. |
| "X saatlik isi silmek israf" | Batik maliyet yanilgisi. Test edilmemis kod teknik borc. |
| "TDD beni yavaslatir" | TDD debugging'den hizli. |

## Kirmizi Bayraklar — DUR ve Bastan Basla

- Test'ten once kod yazdin
- Test hemen PASS etti (mevcut davranisi test ediyorsun)
- Neden FAIL ettigini aciklayamiyorsun
- "Bir kerelik istisna" bahanesi
- "Referans olarak tutayim" (= test'ten sonra yazma)

**Tumu = Kodu sil. TDD ile bastan basla.**

## Dogrulama Listesi

Isi tamamlandi olarak isaretlemeden once:

- [ ] Her yeni fonksiyon/metod icin test var
- [ ] Her test'in fail ettigini gordun
- [ ] Her test beklenen sebeple fail etti (feature eksik, typo degil)
- [ ] Her test icin minimal kod yazdin
- [ ] Tum testler geciyor
- [ ] Testler gercek kod kullaniyor (mock sadece kacinilmazsa)
- [ ] Edge case'ler ve hata senaryolari kapsanmis

## test-scaffold ile Farki

- `test-scaffold`: Test DOSYASI olusturma pattern'leri — naming, yapi, AAA, edge case uretimi
- `tdd`: Gelistirme SURECI — once test yaz, fail gordukten sonra implement et

Birlikte kullanilirlar: TDD sureci icinde test-scaffold pattern'leri uygulanir.

---

Kaynak: obra/superpowers (uyarlanmis versiyon)