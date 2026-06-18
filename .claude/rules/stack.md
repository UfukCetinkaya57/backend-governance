# STACK TESPITI VE YUKLEME

## Kural
Projeye girildiginde aktif stack otomatik tespit edilir.
Tespit edildikten sonra ilgili stack dosyasi **okunmalidir** (otomatik yuklenmez).

## Tespit Mantigi

| Sinyal | Stack | Dosya |
|--------|-------|-------|
| `*.csproj` veya `*.sln` | .NET | Bu klasordeki `dotnet.md` dosyasini OKU |
| `package.json` + Express/Fastify | Node.js | Bu klasordeki `nodejs.md` dosyasini OKU |
| `composer.json` + Laravel | Laravel | Bu klasordeki `laravel.md` dosyasini OKU |

## Uygulama

1. Proje kok dizinindeki dosyalari tara (csproj, package.json, composer.json)
2. Stack'i belirle
3. Ilgili `stack/*.md` dosyasini **acikca oku** (Read)
4. Stack dosyasindaki arac ve pattern'leri uygula

Birden fazla stack tespit edilirse (monorepo), her biri icin ilgili dosya okunur.

## Yeni Stack Ekleme

Yeni stack destegi = bu klasore `yeni-stack.md` eklemek.
Ana governance dosyalari degismez — stack-bagimsizdir.
