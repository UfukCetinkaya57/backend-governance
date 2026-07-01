# 03_SKILLS — Tüm Skill Dosyaları (.claude/skills/)
# backend-governance Project Knowledge Paketi
# 14 skill | Alfabetik sıra | Ham içerik

═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/adr-writer/SKILL.md ===
Boyut: 2.4 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: adr-writer
description: Architecture Decision Record olusturma proseduru
allowed-tools: Read, Write, Glob, Grep
---

# ADR Olusturma Proseduru

Mimari karar dokumante edilecekse bu proseduru takip et.

## Adimlar

### 1. Mevcut ADR'lari Tara

```
Glob: **/docs/adr/*.md, **/adr/*.md, **/ADR-*.md
```

- Mevcut ADR'larin numaralarini bul
- Sonraki numarayi belirle (en buyuk + 1)
- ADR klasoru yoksa `docs/adr/` olustur

### 2. ADR Sablon

Asagidaki sablonu kullan:

```markdown
# ADR-{N}: {Baslik}

**Tarih:** {YYYY-MM-DD}
**Durum:** Teklif
**Karar Veren:** {isim/rol}

## Baglam

Ne sorunu cozuyoruz? Neden bu karar gerekli?
{Somut problem tanimi — soyut degil, gercek durum}

## Karar

{Net bir ifadeyle ne karar verildi}

## Alternatifler

| Secenek | Artilari | Eksileri |
|---------|----------|----------|
| {A} | {artilari} | {eksileri} |
| {B} | {artilari} | {eksileri} |
| {Secilen} | {artilari} | {eksileri} |

## Gerekce

Neden bu secenek secildi? Diger secenekler neden elendi?
{Somut gerekce — "daha iyi" degil, olculebilir veya kanitlanabilir nedenler}

## Sonuclar

### Olumlu
- {beklenen fayda}

### Olumsuz
- {kabul edilen maliyet/trade-off}

### Takip Gerektiren
- {izlenmesi gereken metrik veya risk}
```

### 3. Dosya Isimlendirme

Format: `ADR-{NNN}-{kebab-case-baslik}.md`

Ornekler:
- `ADR-001-veritabani-secimi.md`
- `ADR-002-jwt-stratejisi.md`
- `ADR-003-pagination-yaklasimi.md`

### 4. Dosyayi Olustur

- Dosyayi `docs/adr/` klasorune yaz
- Durum: `Teklif` (kullanici/Team Lead onaylarsa `Kabul` olarak guncelle)

### 5. Raporla

- ADR numarasi ve basligi
- Dosya yolu
- Ozet: ne karar verildi ve neden
- Durum: Teklif (onay bekliyor)

## ADR Gerektiren Durumlar (Referans)

- Yeni pattern veya kutuphane ekleme
- Veri modeli degisikligi (ozellikle veri kaybeden migration)
- API breaking change
- Framework, DB, mimari yaklasim degisimi
- Guvenlik stratejisi degisimi
- Performans optimizasyon yaklasimlari
- Geri donusu 1 saatten fazla surecek herhangi bir karar

## Mevcut ADR Guncelleme

Bir ADR'nin durumu degistiginde:
- `Teklif → Kabul`: Kullanici/Team Lead onayi sonrasi
- `Teklif → Red`: Alternatif secildiyse
- `Kabul → Kaldirildi`: Artik gecerli degilse (yeni ADR ile degistirildi)
- `Kabul → Degistirildi`: Kismi guncelleme (degisiklik notunu ekle)


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/brainstorm/SKILL.md ===
Boyut: 9.2 KB | Son değişiklik: untracked
═══════════════════════════════════════════════════════════════

---
name: brainstorm
description: >
  Yapılandırılmış beyin fırtınası kolaylaştırıcısı. Şu durumlarda tetikle: "beyin fırtınası",
  "fikir üret", "fikir ver", "ne yapabiliriz", "düşünelim", "brainstorm", "bir bakalım",
  "alternatif düşünelim", "ne önerirsin", "kafamda şöyle bir şey var", ya da kullanıcı tıkanmış
  görünüyorsa ("ne yapsam bilmiyorum", "fikrim kalmadı", "I'm out of ideas"). Kapsam: ürün
  fikirleri, içerik planı, problem çözme, isimlendirme, strateji, yaratıcı yazarlık, iş modeli
  ve daha fazlası. Yazılım projeleri İÇİNDE de teknik olmayan ideasyonda geçerlidir — kapsam
  belirleme, özellik önceliklendirme, strateji, pazarlama, kullanıcı araştırma yönleri. Teknik
  tasarım skill'ine YALNIZCA çıktı mimari karar veya kod implementasyonu olduğunda yönlendir.
  Şüphe varsa tetikle.
---

# Beyin Fırtınası Kolaylaştırıcısı

Sen dünya standartlarında bir beyin fırtınası kolaylaştırıcısısın. İşin sadece fikir sıralamak değil —
kullanıcıyı yapılandırılmış bir yaratıcı düşünce sürecinden geçirerek, kendi başlarına bulamayacakları
beklenmedik, işe yarar ve çeşitli fikirler üretmelerini sağlamak.

Kullanıcı hangi dilde yazıyorsa o dilde yanıt ver.

## 3 Aşamalı Süreç

Her beyin fırtınası oturumu üç aşamayı takip eder: **Keşfet → Üret → Değerlendir**. Bu yapı var
çünkü bağlamı anlamadan fikirlere atlamak jenerik sonuçlar üretir, değerlendirme olmadan fikirler
ise sadece gürültüdür. Aşamalar süreci odaklı ve verimli tutar.

---

### Aşama 1: Keşfet (en fazla 2-3 soru)

Fikir üretmeden önce, problem alanını anlamak için 2-3 kısa, hedefli soru sor. Amaç, fikirlerini
10 kat daha isabetli yapacak bağlamı ortaya çıkarmak. Sorguya çekme — hafif ve sohbet havasında tut.

**⚠️ Önce: Soru sormaya gerek var mı, karar ver.**
Herhangi bir şey sormadan önce şu kontrolü yap: kullanıcının mesajı zaten hedefini, kimin için
olduğunu ve ne tür fikirler istediğini söylüyor mu? Evetse — doğrudan Aşama 2'ye geç. Titiz
görünmek için soru sorma. Test şu: "Sormadan fikirlerim anlamlı şekilde farklı olur muydu?"
Cevap hayırsa, direkt üret. Ayrıca kullanıcı "sadece fikir ver", "soru sorma" diyorsa veya
sabırsız görünüyorsa — makul varsayımlarla Aşama 2'ye geç ve ne varsaydığını kısaca belirt ki
düzeltebilsin.

**Soru soracaksan — şunlardan 2-3 tanesini seç:**
- İsteğin arkasındaki gerçek hedef (başarı neye benziyor)
- Kısıtlar (bütçe, zaman, beceri, hedef kitle)
- Daha önce denedikleri veya düşündükleri
- Fikirler kimin için (hedef kitle, paydaşlar)
- Ne kadar "çılgın" gidebileceğin (güvenli hamleler mi, ay'a uçuş mu)

**Nasıl sorulur:**
- Soruları tek bir akıcı mesajda doğal şekilde birleştir, form gibi hissettirme
- Sohbet havasında ol, klinik değil

**Örnek:**
> Kullanıcı: "YouTube kanalım için beyin fırtınası yapalım"
> Sen: "Süper! Daha iyi hedef alabilmem için birkaç şey: Kanalın ne hakkında (ya da ne hakkında
> olmasını istiyorsun) ve ideal izleyicin kim? Bir de — video konu fikirleri mi, büyüme stratejileri
> mi, ikisi birden mi arıyorsun?"

---

### Aşama 2: Üret (yaratıcı motor)

Sihir burada gerçekleşir. Çeşitli, kaliteli fikirler üretmek için bir veya daha fazla düşünme
tekniği kullan. Temel ilke: **çokluk kaliteyi doğurur, ama yapı özgünlüğü doğurur.**

**Duruma göre tekniğini seç:**

| Durum | En İyi Teknik(ler) |
|---|---|
| Ürün/özellik fikirleri | SCAMPER + Hedef Kitle Merceği |
| Problem çözme | Ters Beyin Fırtınası + Kısıt Kaldırma |
| Yaratıcı içerik | Rastgele Bağlantı + Ya Şöyle Olsaydı Senaryoları |
| Strateji/iş | Altı Şapka + İlk İlkeler |
| İsimlendirme/marka | Kelime Çağrışımı + Metafor Madenciliği |
| Genel/belirsiz | 2-3 teknik karışımı |

**Teknik Hızlı Referans:**

- **SCAMPER**: Mevcut bir şeyi al ve elemanlarını Değiştir, Birleştir, Uyarla, Modifiye et,
  Başka amaçla kullan, Ele, veya Tersine çevir.
- **Ters Beyin Fırtınası**: "Bunu nasıl DAHA KÖTÜ yapardık?" diye sor, sonra her cevabı ters çevir.
- **Kısıt Kaldırma**: "Para/zaman/beceri sınırsız olsaydı ne yapardık?" sonra gerçeğe ölçekle.
- **Rastgele Bağlantı**: Alakasız bir alan seç ve probleme bağlantı kurmaya zorla.
- **Altı Şapka**: Probleme duygusal, analitik, yaratıcı, temkinli, iyimser ve organizasyonel
  açılardan bak.
- **İlk İlkeler**: Varsayımları soy, temel gerçekleri belirle, oradan yukarı inşa et.
- **Ya Şöyle Olsaydı**: "Ya [şaşırtıcı kısıt/değişiklik] olsaydı? Yaklaşımımızı nasıl etkilerdi?"
- **Hedef Kitle Merceği**: Farklı kullanıcı personaları veya paydaşların perspektifinden fikir üret.
- **Metafor Madenciliği**: Doğadan, tarihten veya başka alanlardan metaforlar bul ve uygula.
- **Kelime Çağrışımı**: Anahtar kelimelerden serbest çağrışım yaparak beklenmedik yönler keşfet.

**Bu aşama için çıktı kuralları:**
- 7-15 fikir üret (konu genişliğine göre ayarla)
- Fikirleri 2-4 doğal kategoriye grupla — sadece 1'den 15'e numaralama
- Her fikre kısa, vurucu bir başlık + 1-2 cümle açıklama
- En az 1-2 "wild card" fikir ekle (sınırları zorlayan)
- Wild card'ları ⚡ ile işaretle
- Her fikir kümesinin hangi teknikle üretildiğini VE neden o tekniği seçtiğini kısaca belirt
  (ör: "Burada Ters Beyin Fırtınası kullandım çünkü probleminizin bilinen 'bariz' çözümleri var —
  problemi ters çevirmek o kalıplardan kaçmaya yardımcı oluyor." Bu tek cümlelik açıklama süreci
  gizemli değil, işbirlikçi hissettirir.)

**Önemli: Jenerik olma.** Fikirlerin herkes için geçerli olabiliyorsa, çok belirsizdir.
Aşama 1'deki bağlamı kullanarak her fikri spesifik ve uygulanabilir yap.

---

### Aşama 3: Değerlendir ve Rafine Et

Fikirleri sunduktan sonra, kullanıcının onları anlamlandırmasına yardım et. Fikirleri bırakıp gitme.

**Şunu yap:**
- En iyi 3 seçimini öne çıkar ve neden onları seçtiğini kısaca açıkla (kullanıcının bağlamını göz önünde bulundurarak)
- En iyi seçimler için hızlı bir "efor vs. etki" değerlendirmesi sun (her biri için düşük/orta/yüksek)
- Sor: "Hangisi gözüne çarptı? İstersen herhangi birini derinleştirebilirim."

**Kullanıcı favori seçerse:**
- Seçilen fikirleri somut sonraki adımlarla genişlet
- Birbirini tamamlayan fikirleri birleştir
- Seçilen yöne odaklı yeni bir beyin fırtınası turu öner

**Kullanıcı daha fazla isterse:**
- Taze açılar elde etmek için farklı bir tekniğe geç
- Daha sıra dışı bölgelere it
- Neyin rezonans yarattığına göre odağı daralt

**İkinci tur beyin fırtınası ("daha fazla", "derinleş", "daha çılgın fikirler" dediğinde):**
Aşama 2'yi küçük varyasyonlarla tekrarlama — bu tembel hissettirir. Bunun yerine:
1. Hangi *tür* fikirlerin rezonans yarattığını belirle (pratik mi? cesur mu? eğlenceli mi?) ve o yöne ağırlık ver
2. İlk turda kullanmadığın bir teknik kullan — gerçekten yeni açılar üreten budur
3. Kullanıcının favori iki fikrini birleştirerek yeni bir şey oluşturmayı dene (fikir füzyonu)
4. Bir "güvenli" fikri aşırı versiyonuna taşı — "Buna sonuna kadar gitsek ne olur?"
5. Kullanıcı "daha yaratıcı/çılgın/cesur" diyorsa: TÜM pratik kısıtları kaldır ve önce saf
   hayal gücünden üret, sonra uygulanabilirliğe doğru geri çalış

---

## Uyarlanabilir Formatlama

Beyin fırtınası türüne göre en iyi çıktı formatını seç:

- **İş/strateji konuları**: Net başlıklarla yapılandırılmış kategoriler
- **Yaratıcı konular**: Canlı açıklamalarla daha akıcı, anlatı tarzı
- **Problem çözme**: Problem → çözüm yapısı etrafında çerçevele
- **Hızlı beyin fırtınaları** (kullanıcı rahat görünüyorsa): Kısa tut, ağır yapıdan kaçın

Konu karmaşık ve çok boyutluysa, fikirler arasındaki ilişkileri göstermek için girintili madde
yapılarıyla zihin haritası tarzı çıktı üretmeyi düşün.

---

## Ton ve Enerji

- Coşkulu ama yapay değil — gerçek yaratıcı enerji, kurumsal atölye havası değil
- "Evet, ve..." düşüncesi kullan — kullanıcının mevcut düşüncelerini değiştirmek yerine üzerine inşa et
- Oyuncu olmak ve ara sıra metafor ya da analoji kullanmak gayet iyi
- Kullanıcının enerjisini eşle: rahatsa rahat ol, resmiyse sen de öyle ol

---

## Anti-Kalıplar (kaçınılacak şeyler)

- **Bariz fikirleri listeleme.** 5 saniyede herkesin aklına gelebilecek bir şeyse, dahil etme.
- **Belirsiz olma.** "Sosyal medya kullan" fikir değildir. "7 günlük bir Instagram challenge'ı
  başlat, takipçiler kendi versiyonlarını paylaşsın" fikirdir.
- **Aşırı yükleme.** 7-15 fikir ideal nokta. Fazlası gürültü.
- **Aşama 3'ü atlama.** Değerlendirme, beyin fırtınasını aksiyona dönüştüren şeydir.
- **Kullanıcının söylediğini "fikir" olarak geri söyleme.** Değer kat ya da dahil etme.
- **Aşama 1'de 3'ten fazla soru sorma.** Momentum beyin fırtınasında önemlidir.

═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/brainstorming/SKILL.md ===
Boyut: 2.5 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: brainstorming
description: Yeni feature, mimari karar veya tasarim oncesi kullan. Alternatifleri kesfeder, trade-off analizi yapar, tasarimi netlestirir.
---

# Brainstorming — Fikirden Tasarima

## Temel Kural

```
TASARIM ONAYLANMADAN KOD YAZILMAZ. ISTISNASI YOK.
"Basit gorunuyor" gecerli degil. Basit projeler, incelenmemis varsayimlarin en cok zarara verdigi yerdir. Tasarim kisa olabilir (birkaç cumle) ama OLMALI.

## Kontrol Listesi

Sirayla tamamla:

**Proje context'ini incele** — dosyalar, yapilar, son degisiklikler
**Aciklayici sorular sor** — seferde TEK soru, amac/kisitlar/basari kriterlerini anla
**2-3 yaklasim oner** — trade-off'larla, kendi onerinle
**Tasarimi sun** — karmasikliga gore olcekle, her bolumden sonra kullaniciya sor
**Onay al** — kullanici tasarimi onaylayana kadar ilerle
## Surec

### Fikri Anlama

Detayli sorulardan once kapsami degerlendir
Cok buyuk bir istekse (birden fazla bagimsiz alt sistem) → once parcala, hangi sirayla yapilacagini belirle
Uygun kapsamli projeler icin seferde TEK soru sor
Mumkunse coktan secmeli sorular tercih et
Odak: amac, kisitlar, basari kriterleri
### Alternatifleri Kesfet

2-3 farkli yaklasim oner
Her birinin artilari/eksileri
Kendi onerin ve gerekce
Onerini onde sun, neden sectigini acikla
### Tasarimi Sun

Ne yapilacagini anladiginda tasarimi sun
Her bolumu karmasikligina gore olcekle (basit = birkaç cumle, karmasik = detayli aciklama)
Her bolumden sonra sor: "Burasi dogru mu?"
Kapsam: mimari, bilesenler, veri akisi, hata yonetimi, test
Bir sey netlesmediyse geri don, sor
### Tasarim Ilkeleri

**Izolasyon:** Her birim tek bir amaca hizmet etsin, iyi tanimlanmis arayuzlerle iletisim kursun
**Anlasilabilirlik:** Birinin ic detaylari okumadan ne yaptigini anlayabilmesi gerekir
**YAGNI acimadan uygula:** Gereksiz ozellikleri tasarimdan cikar
**Mevcut codebase'e uy:** Yeni pattern onerme, mevcut patternleri takip et. Mevcut kodda sorun varsa ve isi etkiliyorsa, hedefli iyilestirme oner. Alakasiz refactoring YASAK.
## Anti-Pattern: "Buna Tasarim Gerekmez"

Her proje bu surecten gecer. Tek fonksiyonluk utility, config degisikligi, basit CRUD — hepsi. Tasarim belgeniz birkaç cumlede olabilir ama YOKSA = incelenmemis varsayimlar = israf.

## Sonuc

Tasarim onaylandiktan sonra:
- ADR gerekiyorsa yaz (mimari kararlar icin)
- Implementasyon adimlarini belirle
- Uygulama baslasin

---

Kaynak: obra/superpowers (uyarlanmis versiyon)

```

═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/code-audit/SKILL.md ===
Boyut: 4.1 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: code-audit
description: Otonom codebase audit — kesif, tespit, raporlama. Tum projeyi tarar.
allowed-tools: Read, Grep, Glob, Bash
argument-hint: [hedef klasor (opsiyonel, varsayilan: proje koku)]
---

# Codebase Audit

Tum codebase'i sistematik olarak tara, sorunlari tespit et, rapor olustur.
Bu skill quality-gate'ten FARKLIDIR: quality-gate gorev bazli (degisen dosyalar), code-audit proje bazli (tum codebase).

## Ne Zaman Kullanilir

- Projeye ilk giristte genel saglik kontrolu
- Sprint sonu / milestone oncesi review
- Buyuk refactor oncesi durum tespiti
- Periyodik bakim (aylik/sprint bazli)

## Faz 1: Kesif (Yapi Haritasi)

1. Proje kok dizinini tara:
   - Klasor yapisi (Controller, Service, Repository, Model, DTO, Middleware)
   - Dosya sayilari ve buyuklukleri
   - Stack tespiti (csproj, package.json, composer.json)
   - Test dosyalarinin konumu ve sayisi

2. Giris noktalarini belirle:
   - API endpoint'leri (controller/route dosyalari)
   - Middleware pipeline
   - DI/IoC kayitlari
   - Migration dosyalari

3. Yapi haritasi ozeti olustur:
   ```
   src/
     Controllers/ (X dosya)
     Services/    (X dosya)
     Models/      (X dosya)
     ...
   tests/ (X dosya, coverage: ?)
   ```

## Faz 2: Tespit (Sorun Tarama)

Asagidaki kategorilerde sistematik tarama yap. Her kategori icin `grep` pattern'leri ve dosya okuma kullan.

### 2A: Guvenlik (bkz. `.claude/rules/guvenlik.md`)
- [ ] Hardcoded secret/password/API key
- [ ] SQL/NoSQL injection riski (raw query + string concatenation)
- [ ] IDOR potansiyeli (kullanici ID dogrudan parametre)
- [ ] Hassas veri response'da (password, token, hash alanlari)
- [ ] CORS wildcard (`*`) kullanimi
- [ ] Rate limiting eksikligi

```
Grep pattern'leri:
- password|secret|api.?key|token.*=.*["']
- raw.*query|exec.*sql|string.*format.*select
- cors.*origin.*\*
```

### 2B: Performans (bkz. `.claude/rules/kalite.md` Madde 6)
- [ ] N+1 sorgu potansiyeli (dongu icinde DB cagrisi)
- [ ] SELECT * kullanimi
- [ ] Pagination eksikligi (liste endpoint'leri)
- [ ] Index eksikligi (sik sorgulanan alanlar)
- [ ] Gereksiz eager loading veya eksik include

### 2C: Kod Kalitesi (bkz. `.claude/rules/kalite.md` Madde 9)
- [ ] Controller'da is mantigi (Controller → Service katmanlasma ihlali)
- [ ] Kullanilmayan import/using/require
- [ ] Tekrar eden kod bloklari (copy-paste)
- [ ] Cok buyuk dosyalar (>300 satir controller, >500 satir service)
- [ ] TODO/FIXME/HACK yorumlari

### 2D: Hata Yonetimi (bkz. `.claude/rules/kalite.md` Madde 7)
- [ ] Bos catch bloklari (exception yutma)
- [ ] Generic exception yakalama (catch-all)
- [ ] 500 hatasinda detay sizintisi
- [ ] Tutarsiz hata formati

### 2E: Test Durumu (bkz. `.claude/rules/test.md`)
- [ ] Test dosyasi olmayan service'ler
- [ ] Integration test olmayan endpoint'ler
- [ ] Assertion'siz testler
- [ ] Coverage orani (olculebiliyorsa)

### 2F: Veritabani (bkz. `.claude/rules/veri.md`)
- [ ] Rollback'siz migration
- [ ] FK/index eksikligi
- [ ] Isimlendirme ihlalleri (camelCase tablo/kolon)
- [ ] Cascade delete kuralsizligi

## Faz 3: Raporlama

Bulgulari asagidaki formatta raporla:

```
CODEBASE AUDIT RAPORU
=====================
Tarih: {tarih}
Proje: {proje adi}
Stack: {tespit edilen stack}

OZET
----
Toplam dosya: X
Toplam sorun: X (Kritik: X, Yuksek: X, Orta: X, Dusuk: X)

BULGULAR
--------
[KRITIK] {kategori} — {dosya:satir}
  Sorun: {aciklama}
  Oneri: {ne yapilmali}

[YUKSEK] {kategori} — {dosya:satir}
  Sorun: {aciklama}
  Oneri: {ne yapilmali}

...

GENEL SAGLIK
------------
Guvenlik:      [X/6 kontrol gecti]
Performans:    [X/5 kontrol gecti]
Kod Kalitesi:  [X/5 kontrol gecti]
Hata Yonetimi: [X/4 kontrol gecti]
Test:          [X/5 kontrol gecti]
Veritabani:    [X/4 kontrol gecti]

ONCELIKLI AKSIYONLAR
--------------------
1. {en kritik sorun + cozum onerisi}
2. {ikinci oncelikli}
3. {ucuncu oncelikli}
```

## Onemli Kurallar

- Bu skill KOD DEGISTIRMEZ — sadece tespit ve rapor
- Fix onerileri Team Lead'e sunulur, otomatik duzeltme YAPILMAZ
- Mevcut `kalite.md` ve `guvenlik.md` kurallarini referans alir, duplicate etmez
- Raporu kullaniciya goster, dosyaya kaydetme gereksiz (istenirse kaydedilir)


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/commit/SKILL.md ===
Boyut: 2.7 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: commit
description: Governance kurallarına uygun commit yapar
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [commit mesaji (opsiyonel)]
---

# Governance Commit

Governance kurallarına uygun commit olustur. Kurallar:

## Adimlar

### 1. Degisiklikleri Kontrol Et
```
git status
git diff --cached --name-only  (staged dosyalar)
git diff --name-only           (unstaged dosyalar)
```

### 2. Governance Dosyalarini HARIC TUT
Asagidaki dosyalar/klasorler commit'e DAHIL EDILMEZ — staged ise unstage et:
- `.claude/` (agents, rules, skills, settings)
- `CLAUDE.md` (kok dizindeki)
- `backend-governance/` (klasor veya symlink)
- `proje/` (proje profilleri)

```bash
git reset HEAD -- .claude/ CLAUDE.md backend-governance/ proje/ 2>/dev/null
```

### 3. Hassas Dosyalari ENGELLE
Asagidaki dosyalar commit'e ALINMAZ. Staged ise unstage et ve UYAR:
- `.env`, `.env.*`
- `*credentials*`, `*secret*`
- `*.pem`, `*.key`

### 4. Dosya Encoding Kontrolu
Tum dosyalar **UTF-8 BOM** formatinda commit edilmeli.
Commit oncesi degisen dosyalari kontrol et:
```bash
# BOM kontrolu: dosyanin ilk 3 byte'i EF BB BF olmali
file --mime-encoding <dosya>
```
Eger BOM eksikse, dosyanin basina BOM ekle:
```bash
# Python ile BOM ekleme
python3 -c "
import sys
for f in sys.argv[1:]:
    with open(f, 'rb') as fh:
        content = fh.read()
    if not content.startswith(b'\xef\xbb\xbf'):
        with open(f, 'wb') as fh:
            fh.write(b'\xef\xbb\xbf' + content)
        print(f'BOM eklendi: {f}')
" <degisen-dosyalar>
```
**Not:** Binary dosyalar (resim, font, zip vb.) haric tutulur — sadece text dosyalar kontrol edilir.

### 5. Commit Mesaji Olustur
- Kullanici mesaj verdiyse ($ARGUMENTS) onu kullan
- Vermediyse diff'e bakarak kisa, anlasilir mesaj yaz
- **Insan yazmis gibi olmali** — AI ciktisi formati YASAK
- Turkce veya Ingilizce (projenin diline gore)
- Conventional commits formati opsiyonel ama tercih edilir (feat:, fix:, refactor:)
- **Migration varsa:** commit mesajinda acikca belirt. Ornek: `feat: kullanici tablosuna phone_number alani eklendi (migration gerekli)`
- Migration iceren commit'lerde mesajda su bilgiler yer almali:
  - Hangi tablo/alan etkileniyor
  - Migration dosyasinin adi (varsa)
  - Rollback gerektirip gerektirmedigi

### 6. Commit Kurallari
- `Co-Authored-By` satiri **EKLENMEZ** — ASLA
- `--no-verify` kullanilmaz (hook'lar atlanmaz)
- Commit mesaji HEREDOC ile olusturulur (format korumasi icin)

### 7. Commit Et ve Dogrula
```bash
git add <dosyalar>
git commit -m "mesaj"
git status  # dogrulama
```

### 8. Raporla
- Commit edilen dosyalar
- Haric tutulan governance dosyalari (varsa)
- Engellenen hassas dosyalar (varsa)
- BOM eklenen dosyalar (varsa)
- Migration bilgisi (varsa)


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/create-pr/SKILL.md ===
Boyut: 2.4 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: create-pr
description: Governance kurallarına uygun Pull Request olusturur
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [base branch (opsiyonel, varsayilan: master/main)]
---

# Governance PR Olusturma

Pull Request'i governance kurallarına uygun olustur.

## Adimlar

### 1. Branch ve Durum Kontrolu

```bash
git status
git branch --show-current
git log --oneline -5
```

- Mevcut branch'in adini al
- Commit edilmemis degisiklik varsa UYAR (once `/commit` kullan)
- Base branch'i belirle: arguman verilmisse onu kullan, yoksa `master` veya `main`

### 2. Degisiklikleri Analiz Et

```bash
git log {base-branch}..HEAD --oneline
git diff {base-branch}...HEAD --stat
```

- Base branch'ten bu yana tum commit'leri listele
- Degisen dosya sayisi ve turlerini belirle
- Governance dosyalarini filtrele (PR'a dahil olmamali)

### 3. PR Tipi Otomatik Tespit

Commit mesajlarindan PR tipini cikart:
- `feat:` → Feature
- `fix:` → Bug Fix
- `refactor:` → Refactoring
- `docs:` → Documentation
- `test:` → Test
- Karisik → Mixed (en baskin tipi sec)

### 4. Baslik Olustur

- Maksimum 70 karakter
- Format: `{tip}: {kisa aciklama}`
- Insan yazmis gibi, AI formati YASAK
- Turkce veya Ingilizce (projenin diline gore)

### 5. Body Olustur

```markdown
## Ozet
- {1-3 madde: ne yapildi, neden yapildi}

## Degisiklikler
- {degisen dosya/modul listesi, gruplanmis}

## Test Plani
- [ ] {test adimlari}

## Governance Pipeline
- Engineering Mode: {mode}
- Kademe: {hafif/normal/tam}
- Quality Gate: {GECTI/KOSULLU GECTI/calistirilmadi}
- Security Review: {TEMIZ/bulgular var/calistirilmadi}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 6. Governance Kontrolleri

PR olusturmadan once:
- [ ] Governance dosyalari (.claude/, CLAUDE.md, backend-governance/, proje/) commit'lerde YOK
- [ ] Hassas dosyalar (.env, credentials, *.pem, *.key) commit'lerde YOK
- [ ] Kademe geregi quality-gate calistirilmissa sonucu body'ye ekle
- [ ] Tam kademede security-reviewer calistirilmissa sonucu body'ye ekle

Governance dosyasi commit'lerde varsa UYAR ve devam etme.

### 7. PR Olustur

```bash
gh pr create --title "{baslik}" --body "$(cat <<'EOF'
{body}
EOF
)"
```

- Push yapilmamissa once push et: `git push -u origin {branch}`
- PR URL'sini raporla
- Draft olarak acmak icin: `--draft` flag'i ekle

### 8. Raporla

- PR URL'si
- Dahil edilen commit sayisi
- Degisen dosya sayisi
- Haric tutulan governance dosyalari (varsa)
- Governance pipeline durumu


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/governance-eval/SKILL.md ===
Boyut: 7.8 KB | Son değişiklik: 2026-03-22
═══════════════════════════════════════════════════════════════

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


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/migration-checklist/SKILL.md ===
Boyut: 3.2 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: migration-checklist
description: Veritabani migration oncesi kontrol listesi ve rollback proseduru
allowed-tools: Read, Glob, Grep
---

# Migration Kontrol Listesi

Migration yazmadan ONCE ve yazdiktan SONRA bu kontrol listesini uygula.

## Migration ONCESI Kontrol

### 1. Etki Analizi

- [ ] Hangi tablolar etkileniyor?
- [ ] Mevcut veri kaybolur mu? (kolon silme, tip degistirme, tablo silme)
- [ ] Mevcut veri donusumu gerekiyor mu? (data migration)
- [ ] Diger tablolarla FK iliskisi var mi?
- [ ] Index etkileniyor mu?

**Veri kaybeden migration varsa:** Team Lead'e raporla, ADR gerekli.

### 2. Isimlendirme Kontrol

| Oge | Kural | Kontrol |
|-----|-------|---------|
| Tablo | snake_case, cogul | `users`, `order_items` |
| Kolon | snake_case | `first_name`, `created_at` |
| FK | `{entity}_id` | `user_id`, `order_id` |
| Boolean | `is_` / `has_` prefix | `is_active`, `has_permission` |
| Timestamp | `_at` suffix | `created_at`, `updated_at` |
| Index | `ix_{tablo}_{kolon}` | `ix_users_email` |
| Unique | `uq_{tablo}_{kolon}` | `uq_users_email` |

### 3. Zorunlu Alanlar

Yeni tablo olusturuluyorsa, su alanlar ZORUNLU:
- `id` — PK (UUID v7 onerilen / ULID / auto-increment)
- `created_at` — olusturulma (default: now)
- `updated_at` — guncelleme (auto-update)
- Soft delete gerekiyorsa: `deleted_at` (nullable)

### 4. Index Kontrolu

- [ ] FK alanlarina index eklendi mi?
- [ ] Unique constraint gereken alanlara unique index eklendi mi?
- [ ] Sik WHERE kosulunda kullanilacak alanlara index eklendi mi?
- [ ] Composite index gerekiyorsa siralama dogru mu? (en secici alan ilk)

### 5. Veri Tipleri

| Amac | Dogru Tip | YANLIS Tip |
|------|-----------|------------|
| Para/fiyat | DECIMAL(18,2) | FLOAT, DOUBLE |
| Boolean | BOOLEAN | INT, TINYINT |
| Tarih | TIMESTAMP WITH TIMEZONE | VARCHAR, DATE (saat kaybeder) |
| PK | UUID v7 / BIGINT | VARCHAR |

## Migration YAZARKEN

### Rollback (Down) Kurallari

- Rollback metodu **ASLA bos birakilmaz**
- Kolon ekleme → rollback: kolonu sil
- Tablo ekleme → rollback: tabloyu sil (DROP)
- Kolon silme → rollback: kolonu geri ekle (veri kaybolur — bunu dokumante et)
- Tip degistirme → rollback: eski tipe geri don

**Rollback yazilamazsa** (geri donulemez degisiklik):
1. Migration comment'inde acikca belirt: `// IRREVERSIBLE: {neden}`
2. Team Lead'e raporla
3. ADR gerektirir

### Migration Atomikligi

- Her migration TEK bir degisiklik yapmali
- "Tablo olustur + 3 kolon ekle + index ekle" = TEK migration (ayni tablo)
- "Tablo A olustur + Tablo B'ye kolon ekle" = AYRI migration'lar

## Migration SONRASI Kontrol

- [ ] Migration yukarı (up) calisiyor mu?
- [ ] Rollback (down) calisiyor mu?
- [ ] Mevcut veri bozulmuyor mu? (var olan kayitlar)
- [ ] FK constraint'leri dogru calisiyor mu?
- [ ] Index'ler olusmus mu?
- [ ] Cascade delete/update kurallari acikca belirtilmis mi?

## Commit Mesaji

Migration iceren commit'lerde mesajda su bilgiler ZORUNLU:
- Hangi tablo/alan etkileniyor
- Migration dosyasinin adi
- Rollback gerektirip gerektirmedigi (geri donulemez ise acikca belirt)

Ornek: `feat: users tablosuna phone_number alani eklendi (migration: 20260306_add_phone_to_users, rollback mevcut)`


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/security-scan/SKILL.md ===
Boyut: 3.2 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: security-scan
description: Sistematik guvenlik tarama proseduru - otomatik pattern arama ve risk tespiti
allowed-tools: Read, Grep, Glob
---

# Sistematik Guvenlik Taramasi

Kod degisikliklerini sistematik olarak tara. Her adimi sirasi ile uygula, atlama.

## Tarama Sirasi

### Adim 1: Hardcoded Secret Taramasi

Asagidaki pattern'leri tum degisen dosyalarda ara:

```
# API key, secret, password hardcoded mi?
Grep: (password|secret|api_key|apikey|token|credentials)\s*[:=]\s*["'][^"']+["']
Grep: (BEGIN\s+(RSA|DSA|EC|OPENSSH)\s+PRIVATE\s+KEY)
Grep: (ghp_|gho_|github_pat_|sk-|pk_live_|pk_test_|sk_live_|sk_test_)
```

Bulgu varsa → **Ciddiyet: Kritik**

### Adim 2: SQL/NoSQL Injection Taramasi

```
# Raw SQL string birlestirme
Grep: (query|execute|raw|sql)\s*\(.*(\+|`\$\{|f"|\.format)
Grep: (SELECT|INSERT|UPDATE|DELETE|DROP|ALTER).*(\+|concat|\$\{)

# NoSQL injection (MongoDB)
Grep: \$where|\$regex.*req\.(body|query|params)
```

Bulgu varsa → **Ciddiyet: Kritik**

### Adim 3: Command Injection Taramasi

```
# Shell komutu calistirma
Grep: (exec|spawn|system|popen|shell_exec|passthru)\s*\(
Grep: child_process
```

Bulgu varsa → kullanici girdisi akmasi kontrol et. Akiyorsa **Ciddiyet: Kritik**

### Adim 4: IDOR / Authorization Kontrolu

Degisen endpoint'lerde:
- Route parametresinden gelen ID (`:id`, `{id}`) ile kullanicinin kendi verisi mi kontrol ediliyor?
- `req.user.id` veya benzeri ile karsilastirma var mi?
- Admin endpoint'lerinde rol kontrolu var mi?

Bulgu varsa → **Ciddiyet: Yuksek**

### Adim 5: Hassas Veri Sizintisi

```
# Response'da hassas alan donuyor mu?
Grep: (password|passwordHash|hash|token|secret|ssn|creditCard)
```

DTO/response modellerinde bu alanlar var mi kontrol et. Entity dogrudan donduruluyorsa → **Ciddiyet: Yuksek**

### Adim 6: Rate Limiting Kontrolu

Degisen/eklenen endpoint'lerde:
- Rate limiting middleware/decorator/attribute uygulanmis mi?
- Ozellikle: login, register, forgot-password, public endpoint'ler

Eksikse → **Ciddiyet: Orta**

### Adim 7: CORS Kontrolu

```
# CORS konfigurasyonu
Grep: (cors|CORS|Access-Control-Allow-Origin)
Grep: origin.*(\*|null|reflect|req\.headers)
```

Wildcard, null, veya reflect varsa → **Ciddiyet: Yuksek**

### Adim 8: Mass Assignment Kontrolu

- Kullanici girdisi dogrudan entity/model'e bind ediliyor mu?
- `req.body` dogrudan ORM create/update'e gidiyorsa → **Ciddiyet: Orta**
- Admin-only alanlar (role, isAdmin, permissions) korunmus mu?

## Rapor Formati

Her bulgu icin:

```
GUVENLIK TARAMA RAPORU
======================
Taranan dosyalar: {liste}
Tarama tarihi: {tarih}

BULGU #{N}
----------
Ciddiyet: Kritik / Yuksek / Orta / Dusuk
Dosya: {dosya:satir}
Kategori: {Adim adi}
Risk: {ne tehdit var}
Kod: {ilgili kod parcasi}
Cozum: {ne yapilmali}

OZET
----
Kritik: {N} | Yuksek: {N} | Orta: {N} | Dusuk: {N}
Sonuc: {TEMIZ / SORUNLU — detay}
```

## Kurallar

- Tum 8 adimi uygula, "sorun yok gibi gorunuyor" deyip atlama
- False positive'leri de raporla ama "False Positive" olarak isaretle
- Kritik veya Yuksek bulgu varsa → SORUNLU sonucu ver, Team Lead'e escalate
- Tarama sonucu TEMIZ olsa bile rapor olustur (kanit)


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/stack-loader/SKILL.md ===
Boyut: 1.7 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: stack-loader
description: Projenin aktif stack'ini tespit eder ve ilgili stack dosyasini yukler
allowed-tools: Read, Glob, Grep
---

# Stack Tespit ve Yukleme

Projenin aktif stack'ini otomatik tespit et ve stack-spesifik kurallari yukle.

## Adimlar

### 1. Proje Kok Dizinini Tara

Asagidaki dosyalari ara (proje kok dizininde):

| Dosya | Stack |
|-------|-------|
| `*.csproj` veya `*.sln` | .NET |
| `package.json` (Express/Fastify/NestJS iceriyorsa) | Node.js |
| `composer.json` (Laravel iceriyorsa) | Laravel |

```
Glob: **/*.csproj, **/*.sln, **/package.json, **/composer.json
```

### 2. Stack Dogrulama

- `package.json` bulunduysa: dependencies/devDependencies'de express, fastify, nestjs var mi kontrol et
- `composer.json` bulunduysa: require'da laravel/framework var mi kontrol et
- Birden fazla stack sinyali varsa (monorepo): her birini raporla

### 3. Stack Dosyasini Oku

Tespit edilen stack'e gore ilgili dosyayi OKU:

| Stack | Dosya |
|-------|-------|
| .NET | `backend-governance/stack/dotnet.md` |
| Node.js | `backend-governance/stack/nodejs.md` |
| Laravel | `backend-governance/stack/laravel.md` |

**ONEMLI:** Dosya bulunamazsa (stack desteklenmiyor), Team Lead'e raporla ve genel kurallarla devam et.

### 4. Raporla

Stack tespiti tamamlandiginda su bilgileri cikti olarak ver:
- Tespit edilen stack
- Kullanilan framework ve versiyon (package.json/csproj'dan)
- Yuklenen stack dosyasi
- Stack-spesifik onemli notlar (dosyadan)

### Tespit Edilemezse

Stack tespit edilemezse:
1. Team Lead'e bildir
2. Stack-bagimsiz genel kurallarla devam et (`.claude/rules/` otomatik yuklu)
3. Kullanicidan stack bilgisi iste


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/systematic-debugging/SKILL.md ===
Boyut: 4.0 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

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

═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/tdd/SKILL.md ===
Boyut: 4.3 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

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

═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/test-scaffold/SKILL.md ===
Boyut: 3.5 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

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


═══════════════════════════════════════════════════════════════
=== FILE: .claude/skills/yeni-proje/SKILL.md ===
Boyut: 2.8 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

---
name: yeni-proje
description: Governance yapisina yeni proje ekler
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
argument-hint: [proje-adi]
---

# Yeni Proje Ekleme

`$ARGUMENTS` adinda yeni bir proje olustur ve governance yapisina bagla.

## Onkosullar
- `backend-governance/` klasoru mevcut olmali (main2/ altinda)
- Proje adi verilmis olmali ($ARGUMENTS)

## Adimlar

### 1. Proje Klasoru Olustur
```bash
mkdir -p /c/Users/ufukc/OneDrive/Desktop/main2/$ARGUMENTS
cd /c/Users/ufukc/OneDrive/Desktop/main2/$ARGUMENTS
```

### 2. CLAUDE.md Kopyala
Kaynak: `../memory-box/CLAUDE.md` (referans proje)
Hedef: `./$ARGUMENTS/CLAUDE.md`

Kopyaladiktan sonra Deployment bolumundeki proje adini ve path'leri `$ARGUMENTS`'a uyarla.

### 3. Agent Dosyalarini Kopyala
```bash
mkdir -p .claude/agents/
cp ../backend-governance/.claude/agents/*.md .claude/agents/
```
Not: Agent dosyalari KOPYA — symlink degil.

### 4. Rules Symlink Olustur
```bash
mkdir -p .claude/rules/
# Windows junction
cmd //c "mklink /J .claude\rules\governance ..\..\backend-governance\.claude\rules"
```

### 5. Skills Symlink Olustur
```bash
# Windows junction — skills merkezi, tum projeler ayni skill'leri kullanir
cmd //c "mklink /J .claude\skills ..\backend-governance\.claude\skills"
```

### 6. Hooks Symlink Olustur
```bash
# Windows junction — hooks merkezi
cmd //c "mklink /J .claude\hooks ..\backend-governance\.claude\hooks"
```

### 7. Settings.json Kopyala (Hook Config)
```bash
cp ../backend-governance/.claude/settings.json .claude/settings.json
```
Not: settings.json KOPYA — symlink degil (proje bazli override gerekebilir).

### 8. backend-governance Symlink
```bash
# Windows junction
cmd //c "mklink /J backend-governance ..\backend-governance"
```
**ONEMLI:** Clone veya kopya YASAK. Her zaman symlink/junction.

### 9. Proje Profili Olustur
```bash
mkdir -p proje/
cp ../backend-governance/proje/SABLON.md proje/$ARGUMENTS.md
```

### 10. proje/CLAUDE.md Olustur
Icerik:
```markdown
# Aktif Proje

@proje/$ARGUMENTS.md
```

### 11. Proje Kesfi Baslat
Proje klasorunde kod varsa (git repo, package.json, *.csproj vb.):
- `backend-governance/surec/proje-kesfi.md` dosyasini oku
- Otomatik proje kesfini calistir
- `proje/$ARGUMENTS.md` dosyasini doldur

Kod yoksa (bos proje):
- Kullaniciya sor: stack ne olacak?
- SABLON.md'yi minimal doldur

### 12. Dogrulama
- [ ] CLAUDE.md mevcut ve proje adina uyarlanmis
- [ ] .claude/agents/ dosyalari kopyalanmis
- [ ] .claude/rules/governance/ symlink calisiyor
- [ ] .claude/skills/ symlink calisiyor
- [ ] .claude/hooks/ symlink calisiyor
- [ ] .claude/settings.json mevcut (hook config)
- [ ] backend-governance/ symlink calisiyor
- [ ] proje/CLAUDE.md aktif proje isaretli
- [ ] proje/$ARGUMENTS.md olusmus

### 13. Raporla
- Olusturulan klasor yapisi
- Symlink'ler dogru mu
- Siradaki adim: proje kesfini tamamla veya kod yazmaya basla

