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