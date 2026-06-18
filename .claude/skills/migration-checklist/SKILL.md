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
