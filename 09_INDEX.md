# 09_INDEX — Paket Özeti (Project Knowledge Rehberi)
# backend-governance → frontend-governance aktarım paketi
# Üretildi: 2026-05-12 | Versiyon: saf template (main2/ hariç)

═══════════════════════════════════════════════════════════
## 1. PAKET DOSYALARI
═══════════════════════════════════════════════════════════

| Dosya | Boyut | İçerik |
|-------|-------|--------|
| `00_META.md` | 9.4 KB | Klasör yapısı, git log/status/branch, istatistikler, bağımlılık yok |
| `01_RULES.md` | 58.5 KB | 13 kural dosyası (.claude/rules/) — alfabetik, ham içerik |
| `02_AGENTS.md` | 32.2 KB | 6 subagent (.claude/agents/) + agent-memory klasörü (boş) |
| `03_SKILLS.md` | 61.5 KB | 14 skill (SKILL.md + ikincil dosyalar) — alfabetik, ham içerik |
| `04_STACK_SUREC_PROJE.md` | 48.7 KB | stack/ (dotnet+nodejs+laravel) + surec/ + proje/ (SABLON+örnek) |
| `05_HOOKS_SETTINGS.md` | 7.2 KB | pre-commit-guard.sh + settings.json + settings.local.json notu |
| `06_TESTS_EVALS.md` | 35.0 KB | agent-evals + observation-log + session-eval + scorecards + fixtures |
| `07_ROOT.md` | 41.9 KB | CLAUDE.md (ham) + PROJECT_CONTEXT.md (32 KB sistem özeti) |
| `08_USAGE_EVIDENCE.md` | 2.3 KB | Saf template notu + frontend-governance uyarlama rehberi |
| **Toplam** | **296.8 KB** | **9 paket dosyası** |

═══════════════════════════════════════════════════════════
## 2. HER PAKETİN İÇERİĞİ (1-2 cümle)
═══════════════════════════════════════════════════════════

**00_META.md** — Repo'nun tam dizin ağacı (56 dosya, KB cinsinden), son 8 commit'in log'u, git status (3 untracked dosya var), istatistikler ve bağımlılık yok tespiti. Yapıya giriş noktası.

**01_RULES.md** — `.claude/rules/` altındaki 13 otomatik-yüklü kural dosyasının tamamı. api, backend, context, guvenlik, kalite, karar, mimari, operasyon, qa, stack, surec, test, veri — her oturumda tüm agent'lara yüklenir.

**02_AGENTS.md** — 6 subagent'ın (architect, backend-developer, devops, qa-engineer, quality-gate, security-reviewer) YAML frontmatter + sistem promptu. Her agent'ın "Beklenen Input" bölümü handoff şablonu için kritik.

**03_SKILLS.md** — 14 skill'in tamamı. 5 Team Lead skill'i (commit, create-pr, yeni-proje, code-audit, governance-eval) + 9 agent skill'i (stack-loader, security-scan, migration-checklist, adr-writer, test-scaffold, systematic-debugging, tdd, brainstorming, brainstorm).

**04_STACK_SUREC_PROJE.md** — Stack dosyaları (dotnet/nodejs/laravel — manuel okunur, otomatik yüklenmez), süreç prosedürleri (proje-kesfi + deployment), ve proje profilleri (SABLON.md + doldurulmuş memory-box örneği).

**05_HOOKS_SETTINGS.md** — pre-commit-guard.sh (bash hook — governance + hassas dosya koruması, exit 0/2 mantığı), settings.json (hook bağlantısı), settings.local.json (makine-spesifik, atlandı — notla birlikte).

**06_TESTS_EVALS.md** — 7 senaryo içeren agent-evals.md, gözlem logu, session-2026-03-21-evals.md, baseline/trends/scorecards (2 scorecard: %91 baseline ve %100 düzeltme sonrası), ve code-audit fixture JS dosyaları.

**07_ROOT.md** — CLAUDE.md (Team Lead sözleşmesi, 7 KB) ve PROJECT_CONTEXT.md (32 KB — yapıyı hiç görmemiş birinin sistemi anlayabilmesi için yazılmış kapsamlı belge).

**08_USAGE_EVIDENCE.md** — main2/ ve memory verisi kasıtlı atlandı (saf template). Frontend-governance için neyin kopyalanacağı, neyin uyarlanacağı, neyin yeniden yazılacağı rehberi.

═══════════════════════════════════════════════════════════
## 3. KAYNAK İSTATİSTİKLERİ
═══════════════════════════════════════════════════════════

| Metrik | Değer |
|--------|-------|
| Orijinal repo boyutu | ~246 KB |
| Birleştirilen orijinal dosya sayısı | 54 (56 - 2 makine-spesifik) |
| Üretilen paket sayısı | 9 |
| Toplam paket boyutu | ~297 KB |
| Bölme (200 KB üzeri dosya) | GEREKMEDİ — en büyük 61.5 KB |

═══════════════════════════════════════════════════════════
## 4. BULUNAMAYAN / ATLANAN DOSYALAR
═══════════════════════════════════════════════════════════

| Dosya | Durum | Neden |
|-------|-------|-------|
| README.md | YOK | Repo'da bulunmuyor — CLAUDE.md giriş noktası |
| .gitignore | YOK | Repo'da bulunmuyor |
| LICENSE | YOK | Repo'da bulunmuyor |
| CHANGELOG.md | YOK | Repo'da bulunmuyor |
| agent-memory/ içeriği | BOŞ KLASÖR | Henüz agent memory dosyaları yazılmamış |

═══════════════════════════════════════════════════════════
## 5. HASSAS BİLGİ NEDENİYLE ATLANANLAR
═══════════════════════════════════════════════════════════

| Dosya | Neden Atlandı |
|-------|---------------|
| .claude/settings.local.json içeriği | Mutlak path içeriyor: `c:\Users\ufukc\OneDrive\Desktop\...` — makine-spesifik, taşınamaz |
| ~/.claude/projects/memory/ | Kullanıcı-bazlı memory — template'in parçası değil |
| main2/ bağlı projeler | Kasıtlı dışarıda bırakıldı (kullanıcı kararı) |

═══════════════════════════════════════════════════════════
## 6. DİKKAT ÇEKİCİ NOTLAR
═══════════════════════════════════════════════════════════

1. **brainstorm/ vs brainstorming/ çakışması:** İki skill aynı amaca hizmet ediyor.
   - `brainstorming/` (2.5 KB) — architect agent'a bağlı, yazılım tasarımı odaklı
   - `brainstorm/` (9.4 KB) — UNTRACKED, genel-amaçlı kolaylaştırıcı
   - Git status: brainstorming/ MODIFIED, brainstorm/ UNTRACKED
   - Geçiş halinde — frontend-governance kurulumda sadece biri alınmalı

2. **PROJECT_CONTEXT.md UNTRACKED:** 32 KB'lık en kapsamlı belge git'te yok.
   Bu paket üretilirken dahil edildi ama repo'ya commit'lenmeli.

3. **settings.local.json .gitignore'da değil:** İçinde mutlak path olan bu dosya
   git'e commit'lenmemiş ama .gitignore da yok — portability riski.

4. **Toplam 8 commit, aktif geliştirme:** Repo 2026-02-16 initial commit,
   son aktif çalışma 2026-03-22. Yaklaşık 5 haftalık iterasyon.

5. **%100 governance skoru:** Son /governance-eval çıktısı (2026-03-22 v2)
   K1+K2+K3 tümünde %100. Sistemin kendi kendini denetlemesi sağlam durumda.

6. **Windows-only hook:** pre-commit-guard.sh bash gerektiriyor. Windows'ta
   Git Bash ile çalışır. Mac/Linux'ta sorunsuz. mklink /J (yeni-proje skill'inde)
   ise Windows-only — frontend-governance'da cross-platform alternatif düşünülmeli.

7. **settings.local.json içeriği güvenli:** İncelendiğinde sadece Bash izin
   whitelist'i var (dotnet build, git rm komutları). Mutlak path içerdiği için
   yine de template'e dahil edilmedi.

═══════════════════════════════════════════════════════════
## 7. OKUMA SIRASI ÖNERİSİ (Frontend Claude'u İçin)
═══════════════════════════════════════════════════════════

1. **07_ROOT.md → PROJECT_CONTEXT.md bölümü** — Sistemin neden var olduğu ve
   nasıl çalıştığı. 32 KB, her şeyi açıklıyor. Buradan başla.

2. **00_META.md** — Klasör yapısını gözden geçir, neyin nerede olduğunu anla.

3. **07_ROOT.md → CLAUDE.md bölümü** — Team Lead'in sözleşmesi. Frontend'de
   bu dosya uyarlanacak.

4. **02_AGENTS.md** — 6 subagent'ın prompt yapısını gör. Frontmatter standardı
   burada. Backend'deki agent'ları frontend'e uyarlarken referans al.

5. **01_RULES.md → surec.md** — Pipeline diyagramları ve feedback döngüsü.
   Frontend'de de aynı kademe mantığı (hafif/normal/tam) kullanılabilir.

6. **03_SKILLS.md → commit + governance-eval** — Bu iki skill direkt kopyalanabilir,
   governance pattern'leri uyarlanır.

7. **04_STACK_SUREC_PROJE.md → proje/SABLON.md** — Proje profil şablonu.
   Frontend'de aynı yapı çalışır.

8. **06_TESTS_EVALS.md** — Eval altyapısını gör. Frontend senaryoları farklı
   olacak ama format aynı kalabilir.
