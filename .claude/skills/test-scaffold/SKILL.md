---
name: test-scaffold
description: Test dosyasi olusturma pattern'leri - naming, yapi, edge case uretimi
allowed-tools: Read, Write, Glob, Grep
---

# Test Scaffold

Test yazarken bu proseduru takip et. Her test dosyasi icin standart yapi, naming ve minimum edge case listesi uygula.

## Test Dosyasi Yapisi

### 1. Dosya Konumu ve Isimlendirme

Mevcut projenin test yapisini incele:
```
Glob: **/*.test.*, **/*.spec.*, **/tests/**, **/test/**, **/*Tests*, **/*Test.*
```

Mevcut pattern'e uy. Pattern yoksa:
- Test dosyasi, test edilen dosyanin yaninda veya `tests/` klasorunde
- Isimlendirme: `{dosya-adi}.test.{ext}` veya `{dosya-adi}.spec.{ext}`

### 2. Test Yapisi (AAA)

Her test 3 bolumden olusur:

```
Arrange  → Test ortamini hazirla (data, mock, config)
Act      → Test edilecek aksiyonu calistir (TEK bir cagri)
Assert   → Sonucu dogrula (beklenen vs gerceklesen)
```

**Kurallar:**
- Her test TEK bir davranisi test eder
- Testler birbirine bagimli OLMAZ
- Her test kendi verisini olusturur ve temizler

### 3. Test Isimlendirme

Test ismi ne test ettigini acikca belirtmeli:

**Pattern:** `Should_{BeklenenSonuc}_When_{Kosul}`

Ornekler:
- `Should_ReturnNotFound_When_UserDoesNotExist`
- `Should_CreateUser_When_ValidInput`
- `Should_Return401_When_TokenExpired`
- `Should_ThrowValidationError_When_EmailInvalid`

Stack'e gore camelCase veya snake_case kullan (mevcut convention'a uy).

## Minimum Test Senaryolari

### Service (Unit Test) Icin

Her service metodu icin EN AZ:

1. **Happy path** — dogru input, basarili sonuc
2. **Gecersiz input** — null, bos, yanlis tip
3. **Bulunamadi** — var olmayan kaynak (ID yok, kullanici yok)
4. **Yetki hatasi** — yetkisiz erisim denemesi (auth varsa)
5. **Edge case** — sinir degerleri (0, max, negatif, cok uzun string)

### Endpoint (Integration Test) Icin

Her endpoint icin EN AZ:

1. **200/201** — basarili istek, dogru response body
2. **400/422** — gecersiz input, validation hata mesaji kontrolu
3. **401** — token'siz/gecersiz token ile erisim
4. **403** — yetkisiz rol ile erisim (RBAC varsa)
5. **404** — var olmayan kaynak
6. **409** — cakisma (unique constraint varsa — duplicate email, vb.)

### Edge Case Uretici

Asagidaki listeyi her test icin tara, uygulanabilir olanlari yaz:

| Kategori | Degerler |
|----------|----------|
| String | `""`, `" "`, `null`, `undefined`, 1000+ karakter, unicode, emoji, `<script>`, SQL injection (`' OR 1=1`) |
| Sayi | `0`, `-1`, `MAX_INT`, `NaN`, `Infinity`, ondalikli |
| Array/Liste | `[]`, tek eleman, 1000+ eleman, duplicate eleman |
| Tarih | gecmis, gelecek, bugun, `null`, gecersiz format |
| ID | var olmayan, baskasina ait (IDOR), gecersiz format |
| Concurrent | ayni istek 2 kez ayni anda (race condition) |

## Mock Kurallari

- **Mock'la:** Dis servisler (API, email, SMS), DB (unit test'te), dosya sistemi
- **Mock'lama:** Is mantigi, validation, test edilen sinifin kendisi
- **Kural:** Sadece test sinirlarinin DISINDAKI bagimliliklari mock'la
- Asiri mock = gercek davranisi kacirirsin, test anlamsizlasir

## Test Kontrol (Yazdiktan Sonra)

- [ ] Her test TEK bir davranisi test ediyor mu?
- [ ] Test isimleri aciklayici mi?
- [ ] Happy path VE error path var mi?
- [ ] Edge case'ler var mi? (en az 3)
- [ ] Testler birbirinden bagimsiz mi?
- [ ] Deterministic mi? (tarih, random, sira bagimli DEGIL mi?)
- [ ] Assert'siz test yok mu? (her test bir sey dogrulamali)
- [ ] Mock sadece dis bagimliliklarda mi?
