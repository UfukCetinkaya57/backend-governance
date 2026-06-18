---
name: systematic-debugging
description: Bug, test hatasi veya beklenmeyen davranis ile karsilasinca, fix onerisinden ONCE kullan
---

# Sistematik Debugging

## Temel Kural

```
FIX ONERISINDEN ONCE ROOT CAUSE ARASTIRILIR. ISTISNASI YOK.
```

Phase 1 tamamlanmadan fix onerisi YASAK.

## Ne Zaman Kullanilir

- Test hatalari
- Production bug'lari
- Beklenmeyen davranis
- Performans sorunlari
- Build/integration hatalari

**Ozellikle su durumlarda:** Zaman baskisi varsa, "bariz fix" gorunuyorsa, birden fazla fix denemis ama cozemediysen.

## 4 Faz

Her faz tamamlanmadan bir sonrakine gecilmez.

### Faz 1: Root Cause Arastirmasi

**Fix denemeden ONCE:**

1. **Hata mesajini OKU** — stack trace, satir numarasi, hata kodu. Atlamak YASAK.

2. **Yeniden uret** — Ayni hatayi guvenilir sekilde tetikleyebiliyor musun? Edemiyorsan daha fazla veri topla, tahmin etme.

3. **Son degisiklikleri kontrol et** — git diff, son commit'ler, yeni dependency, config degisiklikleri.

4. **Cok katmanli sistemlerde kanit topla:**
   ```
   Her katman sinirinda:
     - Giren veriyi logla
     - Cikan veriyi logla
     - Ortam/config yayilimini dogrula
   Bir kez calistir → NEREDE kirildigini goster
   SONRA o katmani arastir
   ```

5. **Veri akisini izle** — Hatali deger nereden geliyor? Geriye dogru izle, kaynagi bul. Belirtide degil, kaynakta duzelt.

### Faz 2: Pattern Analizi

1. **Calisan ornekleri bul** — Ayni codebase'de benzer ama calisan kod var mi?
2. **Referansla karsilastir** — Pattern uyguluyorsan referansi TAMAMEN oku, gozu kaydirmak YASAK.
3. **Farklari listele** — Calisan ve kirilan arasindaki her fark, ne kadar kucuk olursa olsun.
4. **Bagimliliklari anla** — Hangi bilesenler, ayarlar, ortam gereksinimleri var?

### Faz 3: Hipotez ve Test

1. **Tek hipotez kur** — "X root cause, cunku Y" — acik, net, yazili.
2. **Minimal test yap** — Tek bir degisken degistir, birden fazla seyi ayni anda degistirme.
3. **Dogrula:**
   - Calisti? → Faz 4'e gec
   - Calismadi? → YENI hipotez kur, ustune fix ekleme

### Faz 4: Uygulama

1. **Failing test yaz** — En basit yeniden uretim. Otomasyon mumkunse test framework'u ile.
2. **Tek fix uygula** — Root cause'a yonelik, TEK degisiklik. "Buradayken su da duzelse" YASAK.
3. **Dogrula** — Test geciyor mu? Diger testler kirilmadi mi?
4. **Fix calismadiysa:**
   - < 3 deneme: Faz 1'e don, yeni bilgiyle yeniden analiz et
   - >= 3 deneme: **DUR.** Mimari sorun olabilir. Kullaniciya raporla, karar iste.

## Kirmizi Bayraklar — DUR ve Faz 1'e Don

Su dusunceleri yakalarsan:
- "Simdilik hizli fix, sonra incelerim"
- "X'i degistirip deneyelim bakalim"
- "Birden fazla degisiklik yapip test calistirayim"
- "Test'i atlayip elle kontrol edeyim"
- "Tam anlamadim ama bu calisiabilir"
- "Bir fix daha deneyeyim" (zaten 2+ denemeden sonra)

**Tumu = DUR. Faz 1'e don.**

## Yaygin Bahaneler

| Bahane | Gercek |
|--------|--------|
| "Basit sorun, surece gerek yok" | Basit sorunlarin da root cause'u var. Surec basit sorunlarda hizli. |
| "Acil, surece zaman yok" | Sistematik debugging, rastgele deneme-yanilmadan HIZLI. |
| "Once sunu deneyeyim, sonra arastiririm" | Ilk fix pattern'i belirler. Bastan dogru yap. |
| "Test'i fix'i dogruladiktan sonra yazarim" | Test edilmemis fix'ler tutmaz. Once test, sonra fix. |
| "Birden fazla fix ayni anda zaman kazandirir" | Hangisinin calistigini bilemezsin. Yeni bug'lar uretir. |

## Hizli Referans

| Faz | Anahtar Aktiviteler | Basari Kriteri |
|-----|---------------------|----------------|
| 1. Root Cause | Hata oku, yeniden uret, degisiklikleri kontrol et | NE ve NEDEN'i anla |
| 2. Pattern | Calisan ornekleri bul, karsilastir | Farklari tespit et |
| 3. Hipotez | Teori kur, minimal test et | Dogrulandi veya yeni hipotez |
| 4. Uygulama | Test yaz, duzelt, dogrula | Bug cozuldu, testler geciyor |

## Gercek Dunya Etkisi

- Sistematik yaklasim: 15-30 dk'da fix
- Rastgele fix denemesi: 2-3 saat bocalama
- Ilk seferde dogru fix orani: %95 vs %40
- Yeni bug uretme: Neredeyse sifir vs yaygin

---

Kaynak: obra/superpowers (uyarlanmis versiyon)