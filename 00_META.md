# 00_META — Repo Meta Bilgisi
# backend-governance Project Knowledge Paketi
# Üretildi: 2026-05-12 | Kaynak: backend-governance/ (saf template, main2/ dışı)

═══════════════════════════════════════════════════════════
## 1.1 KLASÖR YAPISI (tam dizin ağacı)
═══════════════════════════════════════════════════════════

backend-governance/
├── CLAUDE.md (7.0 KB)                          ← Team Lead ana sözleşmesi (otomatik yüklü)
├── PROJECT_CONTEXT.md (32.6 KB)                ← Yapıyı anlatan tek belge (bu paketi üreten kaynak)
│
├── .claude/
│   ├── settings.json (0.2 KB)                  ← PreToolUse hook kaydı
│   ├── settings.local.json (0.2 KB)            ← MAKİNE-SPESİFİK (pakete dahil edilmedi)
│   │
│   ├── agents/                                 ← 6 subagent dosyası
│   │   ├── architect.md (4.9 KB)
│   │   ├── backend-developer.md (5.1 KB)
│   │   ├── devops.md (4.0 KB)
│   │   ├── qa-engineer.md (7.8 KB)
│   │   ├── quality-gate.md (4.1 KB)
│   │   └── security-reviewer.md (3.2 KB)
│   │
│   ├── hooks/
│   │   └── pre-commit-guard.sh (1.9 KB)        ← Bash hook — governance + hassas dosya koruması
│   │
│   ├── rules/                                  ← 13 kural dosyası (otomatik yüklü, her oturumda)
│   │   ├── api.md (4.0 KB)
│   │   ├── backend.md (2.5 KB)
│   │   ├── context.md (2.3 KB)
│   │   ├── guvenlik.md (4.7 KB)
│   │   ├── kalite.md (3.6 KB)
│   │   ├── karar.md (3.7 KB)
│   │   ├── mimari.md (3.1 KB)
│   │   ├── operasyon.md (3.8 KB)
│   │   ├── qa.md (7.0 KB)
│   │   ├── stack.md (0.9 KB)
│   │   ├── surec.md (11.0 KB)                  ← En uzun rule dosyası
│   │   ├── test.md (2.5 KB)
│   │   └── veri.md (4.4 KB)
│   │
│   └── skills/                                 ← 14 skill (her biri ayrı klasörde SKILL.md)
│       ├── adr-writer/
│       │   └── SKILL.md (2.4 KB)
│       ├── brainstorm/
│       │   └── SKILL.md (9.4 KB)               ← GIT UNTRACKED — yeni eklendi
│       ├── brainstorming/
│       │   └── SKILL.md (2.5 KB)               ← GIT MODIFIED
│       ├── code-audit/
│       │   └── SKILL.md (4.2 KB)
│       ├── commit/
│       │   └── SKILL.md (2.7 KB)
│       ├── create-pr/
│       │   └── SKILL.md (2.5 KB)
│       ├── governance-eval/
│       │   └── SKILL.md (7.9 KB)
│       ├── migration-checklist/
│       │   └── SKILL.md (3.3 KB)
│       ├── security-scan/
│       │   └── SKILL.md (3.3 KB)
│       ├── stack-loader/
│       │   └── SKILL.md (1.7 KB)
│       ├── systematic-debugging/
│       │   └── SKILL.md (4.1 KB)
│       ├── tdd/
│       │   └── SKILL.md (4.5 KB)
│       ├── test-scaffold/
│       │   └── SKILL.md (3.6 KB)
│       └── yeni-proje/
│           └── SKILL.md (2.9 KB)
│
├── proje/                                      ← Proje profilleri klasörü
│   ├── CLAUDE.md (1.4 KB)                      ← Aktif proje işaretçisi / klasör açıklaması
│   ├── SABLON.md (3.5 KB)                      ← Boş proje profili şablonu
│   └── memory-box.md (5.9 KB)                  ← Doldurulmuş örnek profil (.NET 9 + MySQL)
│
├── stack/                                      ← Stack-spesifik referanslar (manuel okunur)
│   ├── dotnet.md (9.2 KB)
│   ├── laravel.md (11.5 KB)
│   └── nodejs.md (9.5 KB)
│
├── surec/                                      ← Süreç prosedürleri (manuel okunur)
│   ├── deployment.md (1.3 KB)
│   └── proje-kesfi.md (2.1 KB)
│
└── tests/                                      ← Meta-test ve gözlem altyapısı
    ├── agent-evals.md (6.9 KB)                 ← 7 senaryo, agent eval rehberi
    ├── observation-log.md (2.0 KB)             ← Gerçek kullanım gözlemleri
    ├── session-2026-03-21-evals.md (6.5 KB)    ← Belirli oturum eval kayıtları
    ├── fixtures/
    │   └── code-audit-test/                    ← code-audit skill test kodları
    │       ├── controllers/UserController.js (0.5 KB)
    │       ├── migrations/001_create_users.js (0.3 KB)
    │       └── services/AuthService.js (0.6 KB)
    └── results/
        ├── baseline.md (0.7 KB)
        ├── trends.md (0.5 KB)
        └── scorecards/
            ├── 2026-03-22.md (5.8 KB)          ← İlk denetim (%91)
            └── 2026-03-22-v2.md (4.0 KB)       ← Düzeltme sonrası (%100)

═══════════════════════════════════════════════════════════
## 1.2 GIT DURUMU
═══════════════════════════════════════════════════════════

### git log --oneline -30
73385a6 Governance denetim v2: duzeltme dogrulamasi — %91 → %100
57e36a3 Governance denetim sistemi (/governance-eval) ve agent duzeltmeleri
bcdfac6 backend-developer ve qa-engineer'a yeni kurallar ekle
dbd6160 Skill'ler, hook, surec dokumanlari ve agent eval sistemi ekleme
b1a9542 Agent guncellemeleri: memory, skill baglantilari, qa-engineer ekleme
b7c3e20 Kural dosyalarini .claude/rules/ altina tasi, CLAUDE.md'yi sadele
c842a59 Governance framework guncellemesi ve Memory Box proje profili
b512d08 Initial commit: Multi-stack backend governance framework

### git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (modified):   .claude/skills/brainstorming/SKILL.md

Untracked files:
  .claude/settings.local.json
  .claude/skills/brainstorm/
  PROJECT_CONTEXT.md

### git branch -a
* master
  remotes/origin/master

### git log -1 --stat (son commit)
commit 73385a6532d1dba9d0e61f92edf40b37ec43f3c6
Author: UfukCetinkaya57 <UfukCetinkaya57@users.noreply.github.com>
Date:   Sun Mar 22 22:29:09 2026 +0300

    Governance denetim v2: duzeltme dogrulamasi — %91 → %100

 tests/results/scorecards/2026-03-22-v2.md | 86 +++++++++++++++++++++++++++++++
 tests/results/trends.md                   |  1 +
 2 files changed, 87 insertions(+)

═══════════════════════════════════════════════════════════
## 1.3 İSTATİSTİKLER
═══════════════════════════════════════════════════════════

- Toplam dosya sayısı: 56
- Markdown dosya sayısı: 50
- Toplam satır sayısı (tüm markdown): ~6,944 satır
- Toplam boyut: ~246 KB

### En büyük 10 dosya (boyut sıralı)

| Sıra | Dosya | Boyut |
|------|-------|-------|
| 1 | PROJECT_CONTEXT.md | 32.6 KB |
| 2 | stack/laravel.md | 11.5 KB |
| 3 | .claude/rules/surec.md | 11.0 KB |
| 4 | stack/nodejs.md | 9.5 KB |
| 5 | .claude/skills/brainstorm/SKILL.md | 9.4 KB |
| 6 | stack/dotnet.md | 9.2 KB |
| 7 | .claude/skills/governance-eval/SKILL.md | 7.9 KB |
| 8 | .claude/agents/qa-engineer.md | 7.8 KB |
| 9 | CLAUDE.md | 7.0 KB |
| 10 | .claude/rules/qa.md | 7.0 KB |

### Son değişen dosyalar (git log bazlı)

| Tarih | Dosya |
|-------|-------|
| 2026-03-22 | tests/results/scorecards/2026-03-22-v2.md |
| 2026-03-22 | tests/results/trends.md |
| 2026-03-22 | .claude/agents/devops.md (memory: project eklendi) |
| 2026-03-22 | .claude/agents/qa-engineer.md (memory: project eklendi) |
| 2026-03-22 | .claude/agents/architect.md (skill sayısı düzeltildi) |
| 2026-03-22 | .claude/agents/backend-developer.md |
| 2026-03-22 | .claude/skills/governance-eval/SKILL.md |
| 2026-03-22 | tests/results/baseline.md |
| 2026-03-22 | tests/observation-log.md |
| 2026-03-21 | .claude/rules/surec.md |

### Git tracking durumu

| Dosya | Git Durumu |
|-------|------------|
| .claude/skills/brainstorming/SKILL.md | MODIFIED (staged değil) |
| .claude/skills/brainstorm/ | UNTRACKED |
| PROJECT_CONTEXT.md | UNTRACKED |
| .claude/settings.local.json | UNTRACKED |

═══════════════════════════════════════════════════════════
## 1.4 BAĞIMLILIKLAR
═══════════════════════════════════════════════════════════

### package.json
[YOK] — Bu repo bir uygulama değil, kural+agent sistemi. Node.js bağımlılığı yok.

### requirements.txt
[YOK]

### *.csproj / *.sln
[YOK]

### .gitignore
[YOK] — Repo'da .gitignore dosyası bulunmuyor.
Not: settings.local.json untracked ama .gitignore'a eklenmemiş — portability riski
(içinde mutlak path var: c:\Users\ufukc\...).

### README.md
[YOK] — CLAUDE.md ana giriş noktası görevi görüyor.
