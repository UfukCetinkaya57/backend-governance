# VERITABANI STANDARTLARI

## Ilke
Veri katmani = sistemin temeli. Index'siz sorgu, rollback'siz migration kabul edilmez.

---

## Isimlendirme Kurallari

| Oge | Kural | Ornek |
|-----|-------|-------|
| Tablo | snake_case, cogul | `users`, `order_items` |
| Kolon | snake_case | `first_name`, `created_at` |
| Primary Key | `id` (UUID v7 / ULID / auto-increment — bkz. PK secimi) | `id` |
| Foreign Key | `{entity}_id` | `user_id`, `order_id` |
| Boolean | `is_` veya `has_` prefix | `is_active`, `has_permission` |
| Timestamp | `_at` suffix | `created_at`, `updated_at`, `deleted_at` |
| Index | `ix_{tablo}_{kolon}` | `ix_users_email` |
| Unique | `uq_{tablo}_{kolon}` | `uq_users_email` |

---

## Zorunlu Alanlar

Her tabloda bulunmasi GEREKEN alanlar:

```
id          -> Primary Key (proje basinda karar ver, bkz. PK Secimi)
created_at  -> Olusturulma tarihi (default: now)
updated_at  -> Guncelleme tarihi (auto-update)
```

### PK Secimi (ADR ile karar ver)

| Tip | Avantaj | Dezavantaj | Ne Zaman |
|-----|---------|------------|----------|
| UUID v7 | Siralama dostu, distributed-safe, RFC 9562 (2024) | 128 bit, URL'de uzun | **Varsayilan oneri** |
| ULID | Siralama dostu, URL-safe (26 char) | Standart degil (RFC yok) | URL'de gosterilecekse |
| UUID v4 | Basit, yaygin | Random → index fragmentation | Legacy uyumluluk |
| Auto-increment | Kucuk, hizli, index dostu | Distributed'da catisma, tahmin edilebilir | Tek DB, internal |

Soft delete gerekliyse:
```
deleted_at  -> Silinme tarihi (nullable)
is_deleted  -> Boolean flag (opsiyonel, deleted_at yeterli olabilir)
```

---

## Migration Kurallari

- Her migration atomik olmali (tek bir degisiklik)
- Rollback / Down metodu ASLA bos birakilmaz
- Staging'de test edilmeden production'a alinmaz
- Data seed ayri migration/script ile yapilir
- Geri donulemez migration'lar (veri kaybeden) ADR gerektirir

---

## Index Stratejisi

Zorunlu index'ler:
- Primary key (otomatik)
- Foreign key'ler (ORM'e gore otomatik olmayabilir -> kontrol et)
- Unique constraint olan alanlar
- Sik WHERE kosulunda kullanilan alanlar
- ORDER BY'da kullanilan alanlar

Composite index:
- Sik birlikte sorgulanan alanlar icin
- Siralama onemli: en secici alan ilk siraya

Full-text search gerekiyorsa: DB'nin native destegini kullan (PostgreSQL tsvector, vb.)

---

## Query Optimizasyonu

- Sadece gerekli alanlari cek (SELECT * yasak, projection kullan)
- N+1 onlemek icin eager loading / join kullan
- Read-only sorgularda change tracking / dirty checking kapat
- Buyuk join'lerde split query degerlendir
- Pagination zorunlu (bkz. api kurallari — offset vs cursor secimi, otomatik yuklu)
- Count sorgulari ayri calistir (ana sorguyla karistirma)
- Raw SQL sadece performans zorunlulugunda, sebebi yorumla

---

## Iliski Tanimlari

- One-to-One: Acikca tanimla, gereksiz yere kullanma
- One-to-Many: FK parent tabloda degil, child tabloda olmali
- Many-to-Many: Junction table kullan, ekstra alanlar gerekiyorsa entity olarak modelle
- Cascade delete kurallarini acikca belirt (varsayilan kabul etme)

---

## Veri Tipleri

| Amac | Tip |
|------|-----|
| Primary Key | UUID v7 (onerilen) / ULID / BIGINT auto-increment |
| Kisa metin | VARCHAR(n) |
| Uzun metin | TEXT |
| Para/fiyat | DECIMAL(18,2) (FLOAT KULLANMA) |
| Boolean | BOOLEAN |
| Tarih | TIMESTAMP WITH TIMEZONE |
| JSON veri | JSONB (PostgreSQL) / NVARCHAR (SQL Server) |

---

## Transaction & Locking

- Birden fazla tabloyu etkileyen islemler transaction icinde olmali
- Isolation level: varsayilan READ COMMITTED yeterli, gerekmedikce degistirme
- Pessimistic lock (SELECT FOR UPDATE) sadece race condition riski varsa
- Optimistic lock (version/rowversion kolonu) concurrent update senaryolarinda
- Long-running transaction YASAK — islem suresini kisa tut
- Deadlock onleme: her zaman ayni sirada tablo/kaynak kilitle

---

## Kontrol Listesi

- [ ] Isimlendirme kurallarina uygun
- [ ] PK ve audit alanlari (created_at, updated_at) mevcut
- [ ] Soft delete karari alinmis
- [ ] FK'ler tanimli
- [ ] Gerekli index'ler eklenmis
- [ ] Migration olusmus ve rollback yazilmis
- [ ] Iliskiler acikca tanimlanmis
- [ ] Cascade kurallar belirli

ORM-spesifik detaylar (EF Core, Prisma, Eloquent) icin `stack/` dosyasina bak.
