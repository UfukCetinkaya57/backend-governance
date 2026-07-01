# 08_USAGE_EVIDENCE — Kullanım Kanıtı
# backend-governance Project Knowledge Paketi
# Kapsam: Saf template versiyonu — gerçek proje verisi kasıtlı dışarıda

## main2/ Bağlı Projeler

Bu paket sadece backend-governance template'inin saf halini içerir. main2/ altındaki
gerçek projeler (memory-box, sales-app-api, visa-app vb.) ve onların proje profilleri
KASITLI olarak dışarıda bırakıldı. Frontend-governance da aynı template-only yaklaşımla
kurulacak.

## Memory Dosyaları

~/.claude/projects/ altındaki memory dosyalarına bakılmadı — kullanıcı-bazlı veri
içerebilir, template'in parçası değil.

## Agent Invocation History

Atlandı — saf template lazım, kullanım istatistikleri değil.

---

## Template Olarak Kullanım Rehberi (Frontend-Governance İçin)

Bu paketi alan bir Claude oturumu frontend-governance'ı kurarken şu yaklaşımı izlemeli:

### Neyin kopyalanacağı, neyin uyarlanacağı

| Bileşen | Aksiyon | Notlar |
|---------|---------|--------|
| CLAUDE.md | Uyarla | "backend-developer" → "frontend-developer", agent listesi güncelle |
| .claude/rules/*.md | Seç + uyarla | api.md, guvenlik.md, surec.md kısmen geçerli; backend.md → frontend.md yaz |
| .claude/agents/*.md | Uyarla + yenileri ekle | qa-engineer, architect, quality-gate temel yapıyla kalabilir |
| .claude/skills/ | Seç + yenileri ekle | commit, create-pr, governance-eval → direkt kullanılabilir |
| .claude/hooks/pre-commit-guard.sh | Kopyala + uyarla | GOVERNANCE_PATTERNS frontend dizinlerine göre güncelle |
| .claude/settings.json | Kopyala | Aynı hook bağlantısı |
| stack/ | Yeniden yaz | dotnet/nodejs/laravel yerine react/nextjs/vue/angular |
| surec/ | Kısmen kopyala | proje-kesfi.md geçerli, deployment.md uyarla |
| proje/ | Kopyala | SABLON.md aynı yapıyla kullanılabilir |
| tests/ | Kopyala + uyarla | agent-evals.md frontend senaryolarıyla güncelle |

### Yeni yazılacak bileşenler

- `stack/react.md`, `stack/nextjs.md`, `stack/vue.md` — frontend-spesifik araç tabloları
- `.claude/agents/frontend-developer.md` — CSS, component, bundle, a11y kuralları
- `.claude/rules/frontend.md` — Component yapısı, state management, performans
- `.claude/skills/component-scaffold/` — Component oluşturma prosedürü
- `.claude/skills/a11y-check/` — Erişilebilirlik kontrol prosedürü
