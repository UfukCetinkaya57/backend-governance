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
