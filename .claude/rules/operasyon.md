# OPERASYONEL HAZIRLIK

## Ilke
Prod'da bozuldugunda yonetilemiyorsa eksiktir.

---

## 4 Zorunlu Soru

Her feature/deployment icin:
1. **Nasil fark ederiz?** -> Monitoring, alert, health check
2. **Hangi metrik alarm uretir?** -> Esik degerleri belirli
3. **Log'dan kok sebep bulunur mu?** -> Structured logging, correlation ID
4. **Rollback var mi?** -> Her deployment geri alinabilir olmali

---

## Monitoring Metrikleri

| Metrik | Esik | Aksiyon |
|--------|------|---------|
| API response (p95) | > 200ms | Alert |
| Error rate | > %0.5 | Alert (hedef < %0.1 — alarm esigi 5x: anlik spike'lari filtrelemek icin, 1dk pencere) |
| CPU kullanimi | > %80 | Alert |
| Memory kullanimi | > %85 | Alert |
| Uptime | < %99.9 | Kritik alert |
| DB connection pool | > %80 dolu | Alert |
| Queue depth | Proje bazli | Alert |

---

## Health Check

Iki seviye:
- `GET /health/live` → Uygulama calisiyor mu? (liveness)
- `GET /health/ready` → Istekleri alabilir mi? (readiness)

Not: Health check endpoint'leri `/api/v1/` prefix'i ALMAZ — altyapi endpoint'leridir, API degil.

Kontrol edilecekler:
- DB baglantisi
- Cache (Redis) baglantisi
- Disk alani (gerekiyorsa)
- Dis servis baglantilari (gerekiyorsa)

---

## Observability (Gozlemlenebilirlik)

Uc ayak: **Logs + Metrics + Traces**

### Distributed Tracing
- OpenTelemetry (OTel) standart — stack-bagimsiz, vendor-bagimsiz
- Her istek trace ID ile izlenebilir olmali (servisler arasi)
- Span'ler: HTTP istegi, DB sorgusu, dis servis cagrisi
- Export: Jaeger, Zipkin, Grafana Tempo veya cloud-native (Application Insights, Datadog, vb.)
- Stack-spesifik SDK'ler: `stack/` dosyasina bak

### Logging

- **Structured logging** zorunlu (JSON format)
- **Correlation ID** her istekte (request bazli izleme, OTel trace ID ile eslenebilir)
- **Request/Response** loglari (middleware ile)
- **Log seviyeleri:**
  - Info: Normal akis (basarili islemler)
  - Warning: Dikkat gerektiren durum (yavaslik, tekrar deneme)
  - Error: Hata (exception, basarisiz islem)
  - Fatal: Sistem cokmesi (uygulama calismaya devam edemez)

**YASAK loglama:**
- Sifre, token, API key
- Kredi karti bilgisi
- Kisisel saglik/kimlik verisi
- Session verileri

---

## Deployment

### Docker
- Multi-stage build (build + runtime ayri)
- Non-root user
- .dockerignore dosyasi mevcut
- Environment degiskenleri container disinda

### Environment Yonetimi
- Development: local config / user secrets
- Staging: environment variables / secret manager
- Production: Key Vault / secret manager (ASLA hardcoded degil)

### Deployment Stratejisi
- Blue-green veya rolling deployment
- DB migration deployment'tan ONCE ayri adimlarda
- Deployment sonrasi smoke test zorunlu

---

## Rollback Tetikleyicileri

Asagidakilerden biri olusursa hemen rollback:
- Kritik hata (500 error orani ciddi artis)
- Performans dususu (p95 > 500ms)
- Guvenlik acigi tespit
- Veri tutarsizligi

---

## Deployment Checklist

- [ ] Testler gecti (unit + integration)
- [ ] Code review onayli
- [ ] Migration hazir ve test edilmis
- [ ] Environment degiskenleri dogru
- [ ] Rollback plani var
- [ ] Monitoring aktif
- [ ] Deployment onay alindi
- [ ] Smoke test sonrasi "basarili" onaylanacak

---

## Runbook

Kritik akislar icin kisa mudahale adimlari hazirla:

```markdown
## {Akis Adi} - Mudahale Plani

Tetikleyici: {ne olursa}
Ciddiyet: Kritik / Yuksek / Orta
Mudahale adimlari:
1. ...
2. ...
3. ...
Rollback: {nasil}
Eskalasyon: {kime}
```

---

## Performans Hedefleri

| Metrik | Hedef |
|--------|-------|
| API Response (p95) | < 200ms |
| DB Query (avg) | < 50ms |
| Uptime | > %99.9 |
| Error Rate | < %0.1 |
| Test Coverage | > %70 |
