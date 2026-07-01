# backend-governance — Sistem Özeti

> Bu döküman, hiç bu repo'ya bakmamış bir Claude oturumunun yapıyı tek başına anlayabilmesi için yazıldı. Diğer dosyalara referans vermeden okunabilir olmalı.

---

## TL;DR

`backend-governance/`, tek bir Claude Code oturumunu **çok-rollü bir backend mühendislik takımı** gibi davranmaya zorlayan bir kural + agent + skill + hook deposudur. Kullanıcı (junior seviyede, "memnun et beni" yerine "hata yapmamı engelle" isteyen biri) ana oturumla "Team Lead" olarak konuşur; Team Lead kodu kendi yazmaz, `backend-developer`, `security-reviewer`, `quality-gate`, `architect`, `devops`, `qa-engineer` adlı subagent'lara gerekli kademede delege eder. Repo aynı zamanda kendi sağlığını denetleyen bir meta-sistem içerir (`/governance-eval` 3 katmanlı denetim + scorecard trendi).

Bu repo doğrudan bir backend uygulaması DEĞİL — `main2/` altındaki gerçek projelere (`memory-box`, `sales-app-api`, `visa-app`) **junction/symlink ile bağlanan** ortak kural kütüphanesidir.

---

## Neden Var?

Kullanıcı kendini "junior" tanımlayan biri ve LLM'lerin "kullanıcıyı memnun etmek için kötü kodu onaylama" eğilimine karşı bir savunma katmanı istiyor. Tek bir Claude prompt'u ile çalışmak iki problem üretiyor: (1) tüm kuralların aynı context'te tutulması context'i şişiriyor ve LLM'in "lost-in-middle" davranışı yüzünden ortadaki kurallar kaçırılıyor; (2) güvenlik review, kalite kontrol ve mimari kararlar tek bir dikkat akışında çakışıyor. Çözüm: rolleri ayır, subagent'lara temiz context'lerde dağıt, görevi maliyete göre 3 kademeli pipeline'a sok (hafif/normal/tam), her teslimi 11 noktalık kalite kapısından geçir, ve yapının kendisinin de zamanla bozulmadığını periyodik denetimle doğrula.

Ek motivasyon: kullanıcı birden fazla backend projesi yürütüyor (`.NET`, `Node.js`, `Laravel`) ve aynı kuralları tekrar tekrar yazmak yerine **tek kaynaktan** yönetmek istiyor — bu repo o tek kaynak.

---

## Mimari Bakış

```
┌─────────────────────────────────────────────────────────────────┐
│  KULLANICI (Junior — "hata yapmamı engelle" istiyor)             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ konuşur
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  TEAM LEAD (ana Claude oturumu)                                  │
│  - CLAUDE.md + .claude/rules/*.md otomatik yüklü                 │
│  - Edit/Write KULLANMAZ (kod için) — delege eder                 │
│  - Kademe seçer: hafif / normal / tam                            │
│  - Engineering mode seçer: explore / build / harden / incident   │
└─────┬───────────────┬──────────────┬──────────────┬─────────────┘
      │               │              │              │
      ▼               ▼              ▼              ▼
┌──────────┐  ┌──────────────┐ ┌───────────┐ ┌────────────┐
│ backend- │  │ security-    │ │ quality-  │ │ architect  │
│ developer│  │ reviewer     │ │ gate      │ │ devops     │
│ (kod yaz)│  │ (8 adımlı    │ │ (11 nokta │ │ qa-engineer│
│          │  │ tarama)      │ │ checklist)│ │            │
└────┬─────┘  └──────┬───────┘ └─────┬─────┘ └──────┬─────┘
     │               │               │              │
     │ skills:       │ skills:       │              │ skills:
     │ stack-loader  │ security-scan │              │ stack-loader
     │ migration-... │               │              │
     │ test-scaffold │               │              │
     │ tdd           │               │              │
     │ systematic-...│               │              │
     ▼               ▼               ▼              ▼
┌─────────────────────────────────────────────────────────────────┐
│  KURAL KATMANI — .claude/rules/*.md (13 dosya, otomatik yüklü)   │
│  api · backend · context · guvenlik · kalite · karar · mimari   │
│  · operasyon · qa · stack · surec · test · veri                 │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  STACK KATMANI — stack/dotnet.md, nodejs.md, laravel.md         │
│  (manuel okunur, stack-loader skill'i tetikler)                  │
└─────────────────────────────────────────────────────────────────┘

┌─ HOOK ──────────────────────────────────────────────────────────┐
│ .claude/hooks/pre-commit-guard.sh — her `git commit` öncesi     │
│ governance dosyalarını ve hassas dosyaları otomatik unstage    │
└─────────────────────────────────────────────────────────────────┘

┌─ META-DENETIM ──────────────────────────────────────────────────┐
│ /governance-eval skill'i → 3 katman (yapısal/içerik/davranış)   │
│ → tests/results/scorecards/YYYY-MM-DD.md + trends.md            │
└─────────────────────────────────────────────────────────────────┘
```

Üç katman: (1) **Team Lead** orkestrasyon yapar, kararı verir; (2) **Subagent'lar** uzmanlık alanında işi yapar, birbirleriyle DOĞRUDAN konuşmazlar (tüm iletişim Team Lead üzerinden); (3) **Kurallar + skills** her agent'ın context'ine selektif yüklenir.

---

## Bileşenler (Detay)

### Kök dosyalar

| Yol | Görev |
|-----|-------|
| `CLAUDE.md` | Team Lead'in ana sözleşmesi. Rolü ("Team Lead/Koordinatör"), ilk-adım prosedürünü (memory oku → proje dosyası kontrol → stack tespit → mode seç), 3 kademeli pipeline'ı, agent listesini, tamamlanma protokolünü tanımlar. ~7 KB. |
| `proje/CLAUDE.md` | Aktif proje işaretçisi. `@proje/{proje-adi}.md` ile bir proje profilini import eder. |
| `proje/SABLON.md` | Yeni proje profili şablonu (Kimlik, Domain Kuralları, ADR, Kısıtlar, Kritik Akışlar, Ortam tabloları). |
| `proje/memory-box.md` | Doldurulmuş örnek profil — `.NET 9 + MySQL 8 + EF Core` projesi. Diğer projeler bu pattern'i takip eder. |

### `.claude/` — Claude Code yapılandırması

#### `.claude/agents/` (6 subagent)

Her dosya YAML frontmatter + sistem promptu. Frontmatter alanları: `name`, `description`, `tools`, `model`, `maxTurns`, `memory: project`, `skills` (virgülle ayrılmış skill isimleri).

| Agent | Model | Ne yapar | Skills |
|-------|-------|----------|--------|
| `backend-developer.md` | sonnet | Endpoint/service/repo/migration/validation yazar. Kod yazma yetkisi olan tek agent. **ADIM 0:** her görevde önce mevcut testleri çalıştırır. | stack-loader, migration-checklist, test-scaffold, systematic-debugging, tdd |
| `architect.md` | opus | Mimari karar, YAGNI değerlendirmesi, ADR üretimi. Anti-pattern listesi tutar (Repository Her Yerde, Microservice Çünkü Modern, Generic Her Şey vb.). | adr-writer, brainstorming |
| `security-reviewer.md` | opus | 8 adımlı sistematik güvenlik taraması. Kod yazmaz, sadece review yapar. JWT/argon2id/RBAC standartlarını dayatır. | security-scan |
| `quality-gate.md` | sonnet | 11 noktalık kontrol listesi (API/DB/Validation/Auth/Güvenlik/Performans/Hata/Logging/Kalite/Doc/Test). Tek "KAL" varsa → KALDI. Skill yok. |
| `devops.md` | sonnet | Deployment, Docker, monitoring, health check, rollback. 4 zorunlu soru: nasıl fark ederiz, hangi metrik alarm verir, log'dan kök sebep çıkar mı, rollback var mı. | stack-loader, systematic-debugging |
| `qa-engineer.md` | sonnet | **Çalışan sisteme** karşı fonksiyonel test (smoke/E2E/regression). Go/No-Go kararı. Playwright MCP + curl kullanır. Skill yok. |

Her agent'ın "Beklenen Input" bölümü vardır — Team Lead handoff sırasında o listedeki alanları doldurarak çağırmalı, eksikse agent sormalı.

#### `.claude/rules/` (13 dosya, otomatik yüklü)

Her oturumda (Team Lead + tüm agent'lar) context'e eklenir. Dosya başına:

| Dosya | İçerik |
|-------|--------|
| `api.md` | URL yapısı (`/api/v1/{resource}` kebab-case çoğul), HTTP metod tablosu, envelope vs RFC 7807 ProblemDetails seçimi, standart hata kodları, rate limit tablosu, offset vs cursor pagination. |
| `backend.md` | Katman yapısı (Controller→Service→Repository), DI prensipleri, performans soruları (idempotency, N+1, p95). |
| `context.md` | Lost-in-middle kuralı, 4 Kova Modeli (Write/Select/Compress/Isolate), agent handoff şablonu. |
| `guvenlik.md` | 8 zorunlu kontrol (Injection, AuthZ Bypass, Data Leak, Brute Force, Path Traversal/SSRF, CORS, Mass Assignment, Transport). JWT (RS256/HS256), argon2id (memory=19456 KiB, iterations=2), refresh token rotation. Standart auth endpoint seti. |
| `kalite.md` | 11 nokta kalite kapısı detayları. quality-gate agent'ının asıl kaynağı. |
| `karar.md` | YAGNI checklist'i, gerçek-dünya anti-pattern'leri (Repository Her Yerde, Event-Driven Olsun, Microservice Modern, Generic Her Şey, Config'e Taşıyalım). Karar ağacı 3 adımlı. |
| `mimari.md` | Katmanlı→Modüler Monolit→Microservice evrim yolu. ADR şablonu. Bağımlılık yönü kuralları. |
| `operasyon.md` | Monitoring eşikleri (p95>200ms, error rate>%0.5, CPU>%80), `/health/live` ve `/health/ready`, OpenTelemetry, Docker multi-stage, blue-green deployment, rollback tetikleyicileri. |
| `qa.md` | QA vs developer/quality-gate sorumluluk sınırı, test türleri, severity vs priority farkı, Go/No-Go matrisi, risk-based testing tablosu. |
| `stack.md` | Stack tespit mantığı (csproj→.NET, package.json+Express→Node.js, composer.json+Laravel). Stack dosyaları **manuel** okunur. |
| `surec.md` | Pipeline diyagramları (hafif/normal/tam), feedback döngüsü kuralları (max 3 döngü), Görev-Kademe-Agent eşleştirme tablosu, Tamamlanma Protokolü, Kural Evrimi protokolü. ~11 KB — en uzun dosya. |
| `test.md` | AAA yapısı, test isimlendirme (`Should_X_When_Y`), junior hataları (sadece happy-path, aşırı mock, assertion'sız test, deterministik olmayan test). |
| `veri.md` | Migration kuralları, snake_case + çoğul tablo isimlendirme, PK seçimi (UUID v7 önerilen), zorunlu alanlar (id, created_at, updated_at), DECIMAL(18,2) para için, FLOAT yasak. |

#### `.claude/skills/` (14 skill)

Her skill bir alt klasördedir, içinde tek bir `SKILL.md` dosyası vardır. YAML frontmatter: `name`, `description`, opsiyonel `allowed-tools`, opsiyonel `disable-model-invocation`, opsiyonel `argument-hint`. İki tip skill var:

**Team Lead skill'leri** (sadece Team Lead invoke eder, slash command olarak kullanılır):

| Skill | Tetikleyici | Ne yapar |
|-------|-------------|----------|
| `commit/` | `/commit [mesaj]` | Governance dosyalarını (`.claude/`, `CLAUDE.md`, `backend-governance/`, `proje/`) commit'ten dışlar; hassas dosyaları (`.env`, `*.pem`, `*.key`, `*credentials*`) engeller; UTF-8 BOM kontrolü yapar; `Co-Authored-By` satırı **EKLEMEZ**; conventional commits formatı tercih eder. |
| `create-pr/` | `/create-pr [base]` | `gh pr create` ile PR açar; commit tipinden PR tipi çıkarır; body'ye Engineering Mode + Kademe + Quality Gate + Security Review durumunu ekler. |
| `yeni-proje/` | `/yeni-proje <ad>` | `main2/` altına yeni proje klasörü oluşturur, agent'ları KOPYALAR, `rules/`, `skills/`, `hooks/`, `backend-governance/` için Windows junction'ları (`mklink /J`) oluşturur. **`disable-model-invocation: true`** — sadece kullanıcı tetikler. |
| `code-audit/` | `/code-audit [klasör]` | Tüm codebase tarama (3 faz: keşif/tespit/raporlama). quality-gate'ten farkı: quality-gate görev-bazlı, code-audit proje-bazlı. |
| `governance-eval/` | `/governance-eval` | 3 katmanlı denetim (yapısal+tutarlılık+davranışsal). Skor üretir, `tests/results/scorecards/YYYY-MM-DD.md`'ye yazar, `trends.md`'yi günceller. Detay aşağıda. |

**Agent skill'leri** (subagent frontmatter'ında `skills:` ile bağlanmış):

| Skill | Hangi agent | Ne yapar |
|-------|-------------|----------|
| `stack-loader/` | backend-developer, devops | csproj/package.json/composer.json tarayıp stack'i tespit eder, ilgili `stack/*.md` dosyasını okur. |
| `security-scan/` | security-reviewer | 8 adımlı tarama: hardcoded secret, SQL injection, command injection, IDOR, hassas veri sızıntısı, rate limit, CORS, mass assignment. Her adım için `grep` pattern'leri verir. |
| `migration-checklist/` | backend-developer | Migration öncesi/sırası/sonrası kontrol — etki analizi, isimlendirme, zorunlu alanlar (id+created_at+updated_at), index, veri tipleri, rollback (boş bırakmak YASAK), atomik olma. |
| `adr-writer/` | architect | Mevcut ADR'ları glob'lar, sıradaki numarayı belirler, şablon doldurur, `docs/adr/ADR-{NNN}-{kebab-baslik}.md` yazar. Durum: Teklif → Kabul/Red. |
| `test-scaffold/` | backend-developer | Test dosyası lokasyonu, AAA yapısı, naming pattern (`Should_X_When_Y`), minimum senaryolar (service: 5, endpoint: 6), edge case üretici tablosu. |
| `systematic-debugging/` | backend-developer, devops | 4 fazlı debugging: Root Cause → Pattern → Hipotez → Uygulama. "Fix önerisinden ÖNCE root cause" kuralı zorunlu. >=3 deneme = mimari sorun, kullanıcıya rapor. |
| `tdd/` | backend-developer | RED-GREEN-REFACTOR. "Failing test olmadan uygulama kodu yazılmaz" kuralı. |
| `brainstorming/` | architect | Tasarım onaylanmadan kod yok. 2-3 alternatif sun, trade-off, kullanıcı onayı. |
| `brainstorm/` | (Team Lead, model-invoked) | Genel-amaçlı yaratıcı brainstorming kolaylaştırıcısı (3 aşama: Keşfet/Üret/Değerlendir). 9KB, en uzun skill. Diğeri (`brainstorming`) yazılım tasarımı için, bu üst-üste durmasının nedeni belirsiz [varsayım]: `brainstorm/` daha yeni eklendi (26 Mart) ve `brainstorming/` ile yer değiştirebilir. |

#### `.claude/hooks/pre-commit-guard.sh` (PreToolUse hook)

`.claude/settings.json` ile `Bash` matcher'ına bağlanmış. Her `git commit` komutu denenmeden önce bash script çalışır:

1. Komutun `git commit` içerip içermediğini kontrol eder.
2. Staged dosyaları okur.
3. Governance pattern'lerine (`.claude/`, `CLAUDE.md`, `backend-governance/`, `proje/`) uyanları otomatik `git reset HEAD --` ile unstage eder.
4. Hassas pattern'lere (`.env`, `.env.*`, `credentials`, `secret`, `*.pem`, `*.key`) uyanları unstage eder + uyarır.
5. Tüm dosyalar dışlandıysa `exit 2` ile commit'i engeller; kalan varsa `exit 0`.

Bu hook `commit` skill'iyle aynı mantığı tekrarlar — skill kullanıcı tarafına anlatır, hook teknik garantidir (skill atlansa bile çalışır).

#### `.claude/agent-memory/`

Agent başına kalıcı memory için ayrılmış klasörler: `backend-developer/`, `quality-gate/`, `security-reviewer/`. Şu anda boş — agent'ların `memory: project` frontmatter alanı bu klasörleri kullanır [varsayım: tam mekanizma Claude Code'un agent memory feature'ına bağlı, dosya sistemine henüz yazı yok].

#### `.claude/settings.json` ve `.claude/settings.local.json`

`settings.json` — repo'ya commit'lenir, sadece `pre-commit-guard.sh` hook'unu kaydeder.

`settings.local.json` — kullanıcı-makinesi-spesifik permission whitelist (örn. `dotnet build:*`, `git rm:*`). Repo'ya commit'lenmemeli ama şu an `.gitignore` durumunu doğrulayamadım [varsayım: `.gitignore`'a eklenmiş olabilir].

### `stack/` (manuel okunur, otomatik yüklenmez)

| Dosya | Stack'e özel kütüphane/araç tablosu |
|-------|-------------------------------------|
| `dotnet.md` | EF Core, FluentValidation, JwtBearer, Argon2 (Isopoh), Serilog, IDistributedCache+Redis, xUnit+WebApplicationFactory, Mapster, .NET 9'da Scalar (Swashbuckle deprecated). Middleware sırası, DI lifetime kuralları. |
| `nodejs.md` | (içerik okunmadı [varsayım: Express/Fastify/NestJS pattern'leri, Prisma/TypeORM, Vitest/Jest, Joi/Zod validation, Pino logging)] |
| `laravel.md` | (içerik okunmadı [varsayım: Eloquent, FormRequest validation, Sanctum/Passport, Pest/PHPUnit, Telescope/Horizon)] |

### `surec/` (manuel okunur)

| Dosya | İçerik |
|-------|--------|
| `proje-kesfi.md` | Yeni projeye girişte stack tespit + otomatik proje keşfi prosedürü. Ne otomatik tespit edilir (proje adı, DB, durum, cache, CI/CD, auth) ne kullanıcıya sorulur (domain, kritik akışlar, kısıtlamalar). |
| `deployment.md` | Bu governance framework'ünün başka bir projeye nasıl bağlanacağı. İki yöntem: subagent'lı (önerilen) ve subagent'sız (1700 satır context'e yükler). |

### `tests/` — Meta-test ve gözlem altyapısı

| Yol | Görev |
|-----|-------|
| `agent-evals.md` | Agent başına eval senaryoları (SQL injection → security-reviewer, IDOR → security-reviewer, vb.). Beklenen tespitler ve fail anlamı listelenmiş. Manuel çalıştırılır. |
| `observation-log.md` | Gerçek projede gözlemlenen agent davranışları için günlük. Şablon: TARIH+PROJE+AGENT, Senaryo, Gözlem, Beklenen, Tekrar (1./2./tekrar), Aksiyon. Aynı sorun 2. kez görülürse → governance güncellemesi tetiklenir (Kural Evrimi). |
| `session-2026-03-21-evals.md` | Belirli oturumun eval kayıtları. |
| `fixtures/code-audit-test/` | code-audit skill'ini test etmek için kasıtlı sorunlu kod örnekleri (controllers/UserController.js, services/AuthService.js, migrations/001_create_users.js). |
| `results/baseline.md` | İlk `/governance-eval` sonucu (2026-03-22, %91). |
| `results/trends.md` | Tarihsel skor tablosu — şu an 2 satır: %91 (baseline) ve %100 (düzeltme sonrası). |
| `results/scorecards/2026-03-22.md` ve `-v2.md` | Detaylı denetim raporları, her katmanın PASS/FAIL kırılımı. |

---

## Tipik İş Akışı

### Akış A: Yeni feature talebi (Normal kademe örneği)

1. Kullanıcı: "Şu endpoint'i ekleyelim: `POST /api/v1/orders` — kullanıcı sipariş oluşturur."
2. **Team Lead** ilk-adım prosedürünü çalıştırır: `memory/MEMORY.md` okur (zaten otomatik yüklü), `proje/CLAUDE.md` ile aktif projeyi kontrol eder, stack zaten biliniyorsa tekrar taramaz.
3. Team Lead **kademe seçer**: `surec.md`'deki Görev-Kademe-Agent tablosuna bakar — "CRUD endpoint" → **Normal**. Engineering mode: build (auth/ödeme/migration yoksa).
4. Team Lead `backend-developer` agent'ını çağırır. Handoff prompt'u: görev tanımı, mode, aktif stack, beklenen davranış. Önceki agent bulgusu yok (ilk döngü).
5. `backend-developer`:
   - **ADIM 0**: `dotnet test` çalıştırır, baseline'ı bilir.
   - `stack-loader` skill'i ile `stack/dotnet.md` okur.
   - Controller→Service→Repository katmanlama ile kodu yazar.
   - `migration-checklist` skill'iyle (eğer DB değişikliği varsa) migration yazar.
   - `tdd` skill'iyle önce failing test, sonra minimal kod, sonra refactor.
6. Team Lead kodu **code review** eder (iş mantığı, edge case, okunabilirlik).
7. Team Lead `quality-gate` agent'ını çağırır (hafif kontrol — Normal kademede). 11 maddenin sadece etkilenenleri kontrol eder. Her madde GEÇ/KAL.
8. `quality-gate` raporu: `GECTI` → 9. adıma. `KALDI` → `backend-developer`'a geri (max 3 döngü).
9. Team Lead `Tamamlanma Protokolü` çalıştırır: Kanıt Raporu (ne yapıldı, hangi maddeler geçti, kalan risk) + **Proje Genel Durum Raporu** (faz durumu, sıradaki adım, blokerler) — kullanıcı sormadan göstermek zorunda.
10. Kullanıcı `/commit` derse → `commit` skill'i çalışır → governance dosyaları otomatik unstage edilir → conventional commit mesajı yazılır → `Co-Authored-By` **eklenmez** → `pre-commit-guard.sh` hook ek garanti olarak tekrar kontrol eder.

### Akış B: Auth değişikliği (Tam kademe)

1. Kullanıcı: "Refresh token rotation ekleyelim."
2. Team Lead → kademe = **Tam** (auth değişikliği = harden mode tetikleyicisi).
3. Önce `architect` çağırılabilir — yeni pattern mı? `brainstorming` skill'iyle 2-3 alternatif. Mimari karar varsa `adr-writer` skill'iyle ADR yazılır (`docs/adr/ADR-NNN-...md`).
4. `backend-developer` kodu yazar (skills: tdd + test-scaffold).
5. `security-reviewer` `security-scan` skill'iyle 8 adımlı tarama. Risk Raporu formatında bulgular. Sorun varsa → `backend-developer`'a geri (döngü).
6. Team Lead code review.
7. `quality-gate` **tam kontrol** (11 madde tamamı). Tek "KAL" varsa → KALDI.
8. `qa-engineer` (uygulama ayaktaysa) — fonksiyonel test, Go/No-Go kararı.
9. Tamamlanma Protokolü.

### Akış C: Yeni proje ekleme

1. Kullanıcı: `/yeni-proje sales-app-api`.
2. `yeni-proje` skill'i:
   - `main2/sales-app-api/` klasörü oluşturur.
   - `memory-box/CLAUDE.md`'yi referans alıp kopyalar, isim/path uyarlar.
   - `.claude/agents/*.md` **kopyalar** (symlink değil — agent dosyaları proje-bazlı override edilebilir).
   - `.claude/rules/governance/`, `.claude/skills/`, `.claude/hooks/`, `backend-governance/` için Windows junction (`mklink /J`) oluşturur.
   - `.claude/settings.json` kopyalar.
   - `proje/SABLON.md`'yi `proje/sales-app-api.md` olarak kopyalar.
   - `proje/CLAUDE.md` aktif projeyi `@proje/sales-app-api.md` olarak işaretler.
3. Sonra `surec/proje-kesfi.md` prosedürüyle proje keşfi: kod varsa otomatik tarama (proje adı, DB, durum, CI/CD, auth), kullanıcıya sorulan kısımlar (domain, kritik akışlar, kısıtlamalar).

### Akış D: Sistem sağlığı denetimi

1. Kullanıcı: `/governance-eval`.
2. Skill 3 katmanı sırayla çalıştırır:
   - **K1 (yapısal)**: `.claude/agents/`, `.claude/skills/`, `.claude/rules/`'ı tarar — frontmatter eksik mi, orphan skill var mı, kırık referans var mı, fixture klasörleri yerinde mi.
   - **K2 (içerik tutarlılığı)**: `guvenlik.md`'deki 8 kontrolün `security-reviewer.md`'de geçip geçmediği, `kalite.md`'deki 11 maddenin `quality-gate.md`'de olup olmadığı, pipeline tutarlılığı, skill-rule çelişkisi.
   - **K3 (davranışsal)**: K1-K2'deki bulgulara göre **dinamik** tuzak kodu üretir (örn. boş rollback'li migration → backend-developer'a verir, agent yakalıyor mu?). Sabit liste değil — bulguya göre senaryo. 2-5 senaryo. Ağırlık: güvenlik x3, veri bütünlüğü x2, diğer x1.
3. Genel skor = (K1+K2+K3)/3 × 100. Eşikler: 90%+ SAĞLAM, 70-89% YETERLİ, 50-69% ZAYIF, <50% BAŞARISIZ.
4. `tests/results/scorecards/YYYY-MM-DD.md` yazılır, `trends.md` güncellenir.

---

## Konvansiyonlar

**Dil:** Türkçe yazılır (kurallar, agent prompt'ları, skill'ler). İngilizce sadece kod örneklerinde. Karakter seti ASCII-yakın — özel Türkçe karakterler genelde sadeleştirilmiş yazılır ("için" yerine "icin"). [varsayım: Windows shell uyumluluğu için bilinçli tercih].

**Dosya yerleşimi:**
- Tek dosyalık her kural → `.claude/rules/` (otomatik yüklü).
- Stack-spesifik kütüphane bilgisi → `stack/{stack}.md` (manuel okunur).
- Süreç/prosedür → `surec/{ad}.md`.
- Subagent → `.claude/agents/{ad}.md` (kebab-case isim).
- Skill → `.claude/skills/{ad}/SKILL.md` (klasör + tek SKILL.md). İsim kebab-case, Türkçe veya İngilizce karışık (örn. `yeni-proje`, `migration-checklist`).
- Proje profili → `proje/{ad}.md` (ana repo'da örnekler), gerçek projelerde `{proje}/proje/{ad}.md`.
- Test/eval → `tests/`.
- Denetim çıktıları → `tests/results/scorecards/YYYY-MM-DD[-vN].md` ve `trends.md`.

**Frontmatter standardı:**
- Agent: `name`, `description`, `tools`, `model`, `maxTurns`, `memory: project`, opsiyonel `skills`.
- Skill: `name`, `description`, opsiyonel `allowed-tools`, opsiyonel `argument-hint`, opsiyonel `disable-model-invocation: true` (kullanıcının açıkça invoke etmesi gerektiğinde).

**Commit:**
- `Co-Authored-By` satırı **YASAK** (kullanıcı tercihi, memory'de kayıtlı).
- Governance dosyaları (`.claude/`, `CLAUDE.md`, `backend-governance/`, `proje/`) commit'e dahil edilmez — `commit` skill'i + hook ikili olarak korur.
- Conventional commits (`feat:`, `fix:`, `refactor:`) tercih edilir.
- Migration içeren commit'lerde mesajda **migration dosya adı + rollback durumu** açıkça belirtilir.
- `--no-verify` yasak.
- HEREDOC ile yazılır.

**Agent davranışı:**
- "Bitti" demek için kademenin gerektirdiği tüm adımlar geçmiş olmalı.
- Tamamlanma Protokolü zorunlu — kullanıcı sormadan Proje Genel Durum Raporu gösterilir.
- Subagent'lar birbirleriyle DOĞRUDAN konuşmaz — Team Lead aracılık eder.
- Team Lead kod için Edit/Write **kullanmaz**, delege eder. İstisna: governance dosyaları.
- Todo'larda her görev başında sorumlu agent yazılır: `[backend-developer] Endpoint yaz`.

**Çatışma önceliği:** Güvenlik > Doğruluk > Basitlik > Performans. security-reviewer bulgusu her zaman önceliklidir.

**Engineering mode:** explore (PoC, kalite-gate opsiyonel) → build (varsayılan) → harden (auth/ödeme/migration/public API) → incident (canlı hata, veri kaybı). harden = Tam kademe tetikleyici.

---

## Genişletme Rehberi

### Yeni rule eklemek

**Ne zaman:** Aynı hata 2. kez yapıldıysa, security-reviewer/quality-gate tekrar eden bir sorun bulduysa, mevcut kural yetersizse.

1. **Tetikleyici belge:** `tests/observation-log.md`'ye gözlem yaz. "Tekrar: 2. kez" işaretlersen Kural Evrimi protokolü tetiklenir.
2. **Team Lead** kural önerisini formüle eder: hangi dosya, eklenecek tam metin, neden (somut örnek).
3. **Kullanıcı onayı zorunlu** — onay olmadan governance dosyası değişmez.
4. Onaylanırsa: `.claude/rules/{konu}.md` dosyasına eklenir (yeni dosya açmaktansa mevcut konuya ekle, dosyalar şişmesin).
5. İlgili agent'ın frontmatter'ında `description`'ı güncelle (gerekiyorsa).
6. `/governance-eval` çalıştır — yeni kural mevcut yapıyla çelişiyor mu kontrol et.

**Örnek (mevcut):** `surec.md`'de "Max 3 döngü" kuralı — sonsuz feedback döngüsü problemi gözlemlendikten sonra eklenmiş.

### Yeni skill eklemek

1. `.claude/skills/{kebab-case-isim}/SKILL.md` oluştur.
2. Frontmatter:
   ```yaml
   ---
   name: {isim}
   description: {bir cümle — ne zaman tetiklenir, ne yapar}
   allowed-tools: Read, Grep, Glob  # opsiyonel, kısıtla
   argument-hint: [arg]              # opsiyonel
   ---
   ```
3. İçerik: prosedürel — adım adım, kontrol listesi formatlı, somut komut örnekleri (`Glob: ...`, `Grep: ...`, kod blokları).
4. Eğer skill bir agent'a aitse: agent'ın frontmatter'ında `skills: ...` listesine ekle.
5. Eğer Team Lead skill'i (slash command) ise: `disable-model-invocation: true` koy (sadece kullanıcı tetiklesin), `argument-hint` ekle.
6. `governance-eval`'in K1 kontrolü "orphan skill yok mu" doğrular — bağlanmamış skill FAIL üretir.

**Pattern (örnek `security-scan`):** "Adım N: {ne}" başlıkları + her adımda `Grep: <pattern>` + ciddiyet ataması (Kritik/Yüksek/Orta/Düşük) + sonda Rapor Formatı.

### Yeni agent eklemek

1. `.claude/agents/{ad}.md` oluştur.
2. Frontmatter (zorunlu): `name`, `description`, `tools`, `model` (sonnet/opus), `maxTurns`, `memory: project`.
3. Sistem promptu bölümleri: "Memory Kullanımı", "Skill'ler", "Beklenen Input (Team Lead'den)", "Görev Başında", uzmanlığa özel kontroller, çıktı formatı.
4. Mevcut agent'larla rol çakışmadığından emin ol — `qa.md`'deki "QA vs diğer roller" tablosu gibi sınırlar net olmalı.
5. `CLAUDE.md`'deki agent tablosuna ekle (Team Lead'in haberi olsun).
6. `surec.md`'deki Görev-Kademe-Agent eşleştirme tablosunu güncelle.
7. Pipeline diyagramlarına nereye girdiğini ekle.
8. `governance-eval` K1 kontrolü beklenen agent listesinde olmasını arar — listede güncelleme gerekebilir.

### Yeni stack desteği

1. `stack/{ad}.md` oluştur. Mevcut `dotnet.md` formatını takip et: Tespit, Teknoloji Tablosu, Middleware/Pipeline sırası, DI/IoC kuralları, API pattern'leri, ORM kuralları, Test araçları, Logging.
2. `.claude/rules/stack.md`'deki tespit sinyali tablosuna satır ekle.
3. `.claude/skills/stack-loader/SKILL.md`'deki tablolara satır ekle.
4. `surec/proje-kesfi.md`'deki tespit tablosunu güncelle.

### Yeni proje bağlamak

`/yeni-proje <ad>` skill'i otomatik yapar (Akış C). Manuel yapılacaksa: agent'lar **kopya**, `rules/` + `skills/` + `hooks/` + `backend-governance/` **junction/symlink** (asla clone — sync bozulur, eski kalır, memory'de kayıtlı bir hatadır bu).

---

## Açık Sorular / Belirsizlikler

1. **`brainstorm/` vs `brainstorming/` çakışması:** İki skill aynı amaca hizmet ediyor. `brainstorming/` yazılım tasarımı odaklı (architect agent'a bağlı), `brainstorm/` genel-amaçlı 9 KB'lık bir kolaylaştırıcı (.claude/settings.local.json'da olmayan ama working tree'de modified durumda). Hangisi kalacak, hangisi kaldırılacak? `git status` "M .claude/skills/brainstorming/SKILL.md" ve "?? .claude/skills/brainstorm/" gösteriyor — geçiş halinde olabilir. **Kullanıcıya sorulmalı.**

2. **`.claude/agent-memory/` mekaniği:** Klasörler boş. Frontmatter'daki `memory: project` alanının bu klasörlerle nasıl bağlandığı Claude Code feature'ına bağımlı [varsayım]. Şu anda hiçbir agent bu klasöre yazı dökümamış görünüyor.

3. **`tests/` ve `tests/results/` projeye dahil mi:** Eval/scorecard dosyaları repo'ya commit'leniyor. Bu kasıtlı — trend takibi için mantıklı — ama hassas/proje-spesifik bilgi içerirse problem olabilir. Şu an temiz, sorun yok.

4. **`stack/nodejs.md` ve `stack/laravel.md` içeriği:** Bu özet için sadece `dotnet.md` baştan okundu. Diğer ikisi için sadece dosya boyutlarına ve isim listesine bakıldı [varsayım: `dotnet.md` ile aynı yapıda, framework-spesifik araç ismi farkı var].

5. **`settings.local.json` git tracking:** İçinde makineye-özel mutlak path var (`Bash(git -C "c:\\Users\\ufukc\\OneDrive\\Desktop\\..."`). `.gitignore`'a alınmış mı doğrulanmadı — alınmadıysa portability sorun olur.

6. **`yeni-proje` skill'inde Windows-only komutlar:** `cmd //c "mklink /J ..."` Windows junction kullanıyor. Cross-platform (Mac/Linux) çalışmıyor. Kullanıcının Windows'ta olduğu açık (CLAUDE.md'de Platform: win32) ama ileride taşınırsa adapte gerekecek.

7. **`session-2026-03-21-evals.md` formatı:** Görüldü ama içeriği okunmadı [varsayım: belirli bir oturumda manuel çalıştırılan eval'ların kayıtları, observation-log.md ile ilişkili olabilir].

8. **`memory/MEMORY.md` lokasyonu:** CLAUDE.md `memory/MEMORY.md` referans veriyor ama bu klasör repo kökünde yok — `C:\Users\ufukc\.claude\projects\c--Users-ufukc-OneDrive-Desktop-main2-backend-governance\memory\` yolunda kullanıcı-bazlı yaşıyor. Bu, Claude Code'un auto-memory feature'ının çıktısı [varsayım: framework'un dışında, harness yönetir].
