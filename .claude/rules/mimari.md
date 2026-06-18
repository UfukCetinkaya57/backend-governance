# MIMARI TUTARLILIK

## Ilke
Bugunku hiz, yarinin borcu olmamali.

---

## 3 Mimari Kontrol

Her mimari degisiklikten once:
1. **Geri donusu zor mu?** -> Zorsa ADR yaz, onay al
2. **Domain sinirlarini ihlal ediyor mu?** -> Bir servisin baska servisin isini yapmasi
3. **Sorumluluklar net mi?** -> Her katman/sinif/modul tek sorumluluk

---

## Mimari Yaklasim

Mimari yaklasim proje bazinda `architect` tarafindan belirlenir. Asagidaki secenekler ve evrim yolu referanstir — sabit bir varsayilan YOKTUR.

### Baslangic Noktasi: Katmanli (Layered / N-Tier)

```
Controller (HTTP) -> Service (Is mantigi) -> Repository (Veri erisimi) -> Entity (Domain)
```

Not: Bu pattern bazen "Clean Architecture" olarak anilir ama gercek Clean Architecture
(Uncle Bob) ports/adapters ve dependency inversion ile daha katli kurallar icerir.
Biz burada pragmatik katmanli mimariyi kastediyoruz.

Katmanli mimaride kurallar:
- Bagimlilik yonu daima iceriden disariya (Entity hicbir seye bagimli degil)
- Controller sadece Service'i cagirir, Repository'yi dogrudan CAGIRMAZ
- Service baska Service'i cagirabilir, ama dairesel bagimliligi ONLE
- Cross-cutting concern'ler (logging, auth, cache) middleware/interceptor ile

### Evrim Yolu (her gecis ADR gerektirir)

1. **Katmanli mimari** (basla) → cogu proje icin yeterli
2. **Moduler monolit** (buyuyunce) → feature-based moduller, modul sinirlarinda interface
3. **Microservice** (somut olcekleme ihtiyacinda) → bagimsiz deploy gerektiren modul var

Proje profili ve gereksinimler hangi noktadan baslanacanigi belirler. `architect` bu karari verir ve ADR ile dokumante eder.

CQRS, Event Sourcing, Hexagonal Architecture gibi ileri pattern'ler icin somut gerekce + ADR zorunlu.

---

## ADR Zorunlu Durumlar

Asagidaki durumlarda Architecture Decision Record olusturulmali:
- Yeni pattern veya kutuphane ekleme
- Veri modeli etkisi / migration (ozellikle veri kaybeden)
- Uzun vadeli karar (framework, DB, mimari yaklasim)
- API tasarim degisikligi (breaking change)
- Guvenlik stratejisi degisimi
- Performans optimizasyon yaklasimlari
- Geri donusu zor herhangi bir karar

---

## ADR Formati

```markdown
# ADR-{N}: {Baslik}

**Tarih:** YYYY-MM-DD
**Durum:** Teklif | Kabul | Red | Kaldirildi | Degistirildi
**Karar Veren:** {isim/rol}

## Baglam
Ne sorunu cozuyoruz? Neden bu karar gerekli?

## Karar
Net bir ifadeyle ne karar verildi.

## Alternatifler

| Secenek | Artilari | Eksileri |
|---------|----------|----------|
| A | ... | ... |
| B | ... | ... |

## Gerekce
Neden bu secenegin secildigi.

## Sonuclar
- Olumlu: ...
- Olumsuz: ...
- Takip gerektiren: ...
```

---

## Anti-Pattern'ler

- God Service: Tek bir service'in her isi yapmasi -> bol
- Leaky Abstraction: Alt katman detaylarinin ust katmana sizmasi
- Circular Dependency: A -> B -> A bagimlilik dongusu
- Premature Abstraction: Tek kullanim icin interface/abstract sinif
- Config Sprawl: Konfigurasyonun kontrolsuz dagilmasi

Karar verme cercevesi ve YAGNI kontrolleri icin bkz. karar kurallari (otomatik yuklu).
