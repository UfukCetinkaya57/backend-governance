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
