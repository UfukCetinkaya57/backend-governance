# TEST DISIPLINI

## Ilke
Test = guvenin kaniti.

---

## 3 Zorunlu Soru

Her feature/degisiklik icin:
1. Nerede bozulur?
2. Edge-case ne?
3. Hata aninda davranis ne?

---

## Test Turleri

### Unit Test
- **Ne:** Is mantigi (service katmani)
- **Nasil:** Dis bagimliliklari mock'la, tek bir davranisi test et
- **Ne zaman:** Her service metodu icin

### Integration Test
- **Ne:** API endpoint'leri, DB islemleri, dis servis entegrasyonlari
- **Nasil:** Tam HTTP pipeline veya gercek DB ile
- **Ne zaman:** Her endpoint icin, her dis bagimlilikte

### Regression Test
- **Ne:** Daha once bulunan bug'lar
- **Nasil:** Bug'i yeniden ureten test yaz, fix'i dogrula
- **Ne zaman:** Her bug fix sonrasi (zorunlu)

---

## Test Yapisi

```
Arrange  -> Test ortamini hazirla (data, mock, config)
Act      -> Test edilecek aksiyonu calistir
Assert   -> Sonucu dogrula
```

Her test TEK bir davranisi test etmeli.
Test isimleri ne test ettigini acikca belirtmeli:
`Should_ReturnNotFound_When_UserDoesNotExist`

---

## Test Hiyerarsisi (Stack-Bagimsiz)

| Katman | Test Turu | Mock/Gercek |
|--------|-----------|-------------|
| Service | Unit | Dis bagimliliklari mock'la |
| Controller/Endpoint | Integration | Tam HTTP pipeline |
| Repository/DB | Integration | In-memory veya gercek DB |
| Middleware | Integration | Tam pipeline |
| Validator | Unit | Izole |

---

## Kapsam Hedefleri

| Metrik | Hedef |
|--------|-------|
| Unit test coverage | > %70 |
| Her endpoint'in integration testi | Zorunlu |
| Auth/permission testleri | Zorunlu |
| Edge case testleri | Her feature icin en az 3 |
| Hata senaryosu testleri | Her endpoint icin en az 1 |

---

## Junior Hatalari (Bunlari YAPMA)

1. **Sadece happy-path test**
   - Basarili senaryo yetmez, hata senaryolari da test et

2. **Asiri mock**
   - Her seyi mock'larsan gercek davranisi kacirir, test anlamsizlasir
   - Kural: sadece test sinirlarinin disindaki bagimliliklar mock'lanir

3. **Assertion'siz test**
   - Test calisiyor ama bir sey dogrulamiyor = test degil

4. **Test isolation eksik**
   - Testler birbirine bagimli olmamali
   - Her test kendi verisini olusturup temizlemeli

5. **Deterministic olmayan test**
   - Tarih, random deger, siraya bagimlilik = flaky test
   - Sabit degerler veya test clock kullan

---

Stack-spesifik test araclari ve framework'ler icin `stack/` dosyasina bak.
