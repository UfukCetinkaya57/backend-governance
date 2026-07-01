# 04_STACK_SUREC_PROJE — Stack, Süreç ve Proje Dosyaları
# backend-governance Project Knowledge Paketi
# stack/ (3 dosya) + surec/ (2 dosya) + proje/ (3 dosya)

# ════════════════════════════════════════════════════════════
# BÖLÜM A: STACK DOSYALARI (stack/)
# stack-loader skill ve backend-developer tarafından manuel okunur
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: stack/dotnet.md ===
Boyut: 9.0 KB | Son değişiklik: 2026-02-16
═══════════════════════════════════════════════════════════════

# .NET / ASP.NET CORE STACK REFERANSI

## Tespit
- `*.csproj` veya `*.sln` dosyasi mevcut -> bu stack aktif

---

## Teknoloji Tablosu

| Katman | Arac |
|--------|------|
| Framework | ASP.NET Core Web API (.NET 8+) |
| ORM | Entity Framework Core |
| Validation | FluentValidation |
| Auth | Microsoft.AspNetCore.Authentication.JwtBearer |
| Password | Isopoh.Cryptography.Argon2 (argon2id, onerilen) veya BCrypt.Net-Next (kabul edilir) |
| Logging | Serilog |
| Cache | IDistributedCache + StackExchange.Redis |
| Test | xUnit + WebApplicationFactory + FluentAssertions |
| Mock | Moq veya NSubstitute |
| Test Data | Bogus / AutoFixture |
| API Docs | .NET 9+: Microsoft.AspNetCore.OpenApi + Scalar. .NET 8: Swashbuckle (deprecated in .NET 9) |
| Mapping | Mapster veya Mapperly (source generator). AutoMapper onerilmez (debug zorlugu, silent failure) |
| Health Check | Microsoft.Extensions.Diagnostics.HealthChecks |

---

## Middleware Pipeline Sirasi

```csharp
app.UseExceptionHandler();       // 1. Global exception handler
app.UseSerilogRequestLogging();  // 2. Request/Response logging
app.UseCors();                   // 3. CORS
app.UseRateLimiter();            // 4. Rate limiting (.NET 7+)
app.UseAuthentication();         // 5. Authentication
app.UseAuthorization();          // 6. Authorization
app.MapControllers();            // 7. Endpoint routing
```

Sira ONEMLIDIR. Degistirirsen davranis degisir.

---

## Dependency Injection Lifetime

| Lifetime | Ne Zaman | Ornek |
|----------|----------|-------|
| Scoped | Request-bazli | DbContext, UnitOfWork, Service'ler |
| Transient | Her cagrildiginda yeni | Stateless utility, validator |
| Singleton | Uygulama omru boyunca | IMemoryCache, HttpClientFactory, config |

**KURALLAR:**
- DbContext ASLA Singleton olmaz
- Singleton servis Scoped servisi inject EDEMEZ
- Extension metot ile grupla: `services.AddAuthServices()`, `services.AddProductServices()`

---

## API Pattern'leri

### Controller-Based (Varsayilan, karmasik endpoint'ler icin)
```csharp
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class UsersController : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<UserDto>>), 200)]
    public async Task<ActionResult<ApiResponse<List<UserDto>>>> GetAll(
        [FromQuery] PaginationRequest request,
        CancellationToken cancellationToken)
    { }
}
```

### Minimal API (.NET 8+, basit CRUD endpoint'ler icin)
```csharp
var group = app.MapGroup("api/v1/users").RequireAuthorization();

group.MapGet("/", async ([AsParameters] PaginationRequest req, IUserService service, CancellationToken ct) =>
    Results.Ok(await service.GetAllAsync(req, ct)));

group.MapGet("/{id:guid}", async (Guid id, IUserService service, CancellationToken ct) =>
    await service.GetByIdAsync(id, ct) is { } user
        ? Results.Ok(user) : Results.NotFound());
```

**Secim:** Minimal API basit endpoint'ler icin, Controller karmasik logic + attribute'lar gerektiginde.

**KURALLAR (her iki yaklasimda):**
- CancellationToken her async metotta
- [FromBody], [FromQuery], [FromRoute] acikca belirt
- Response tipleri dokumante edilmis

---

## EF Core Kaliplari

### Entity Configuration (ayri dosyada)
```csharp
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Email).IsRequired().HasMaxLength(255);
        builder.HasIndex(x => x.Email).IsUnique();
        builder.HasQueryFilter(x => !x.IsDeleted); // Soft delete
    }
}
```

### Zorunlu Kurallar
- `AsNoTracking()` -> read-only sorgularda ZORUNLU
- `Include()` / `ThenInclude()` -> N+1 onlemek icin
- `AsSplitQuery()` -> buyuk join'lerde degerlendir
- `Select()` -> projection, sadece gerekli alanlar
- Raw SQL -> sadece performans zorunlulugunda, yorumla
- Migration `Down()` metodu -> ASLA bos birakilmaz

### Migration
```bash
dotnet ef migrations add {IsimAciklayici}
dotnet ef database update
```

---

## FluentValidation

```csharp
public class CreateUserValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(255);
        RuleFor(x => x.Password).NotEmpty().MinimumLength(8)
            .Matches("[A-Z]").WithMessage("En az bir buyuk harf")
            .Matches("[a-z]").WithMessage("En az bir kucuk harf")
            .Matches("[0-9]").WithMessage("En az bir rakam")
            .Matches("[^a-zA-Z0-9]").WithMessage("En az bir ozel karakter");
    }
}
```

Pipeline behaviour ile otomatik validation (MediatR kullaniliyorsa).
Yoksa controller'da `ModelState` veya filter ile.

---

## Serilog

```csharp
Log.Logger = new LoggerConfiguration()
    .Enrich.FromLogContext()
    .Enrich.WithCorrelationId()
    .WriteTo.Console()  // Development
    .WriteTo.Seq(url)   // Production (veya Elasticsearch, AppInsights)
    .CreateLogger();
```

Hassas veri maskeleme:
```csharp
.Destructure.ByTransforming<LoginRequest>(r => new { r.Email, Password = "***" })
```

---

## Authentication (JWT)

```csharp
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            // RS256 icin: IssuerSigningKey = new RsaSecurityKey(rsaKey)
        };
    });
```

Password hashing (bkz. `guvenlik/CLAUDE.md` — argon2id onerilen):
```csharp
// Onerilen: Isopoh.Cryptography.Argon2 (aktif bakimli, NuGet)
// NOT: Konscious.Security.Cryptography 2019'dan beri guncellenmemis — KULLANMA
using Isopoh.Cryptography.Argon2;

var config = new Argon2Config
{
    Type = Argon2Type.DataIndependentAddressing, // argon2id
    Password = Encoding.UTF8.GetBytes(password),
    Salt = RandomNumberGenerator.GetBytes(16),
    MemoryCost = 19456, // KiB (OWASP minimum)
    TimeCost = 2,       // iterations
    Lanes = 1           // parallelism
};
var hash = Argon2.Hash(config);
var isValid = Argon2.Verify(hash, password);

// Kabul edilir: BCrypt.Net-Next
var bcryptHash = BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
var verified = BCrypt.Net.BCrypt.Verify(password, bcryptHash);
```

---

## Test

### Unit Test (xUnit + Moq)
```csharp
public class UserServiceTests
{
    [Fact]
    public async Task GetById_Should_ReturnNotFound_When_UserDoesNotExist()
    {
        // Arrange
        var repo = new Mock<IUserRepository>();
        repo.Setup(r => r.GetByIdAsync(It.IsAny<Guid>())).ReturnsAsync((User?)null);
        var service = new UserService(repo.Object);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(() => service.GetByIdAsync(Guid.NewGuid()));
    }
}
```

### Integration Test (WebApplicationFactory)
```csharp
public class UsersApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UsersApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetAll_Should_Return200_With_UserList()
    {
        var response = await _client.GetAsync("/api/v1/users");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
```

### Test DB
- **Testcontainers** (onerilen — gercek DB container ile test, en guvenilir sonuc)
- SQLite in-memory (hizli, cogu constraint destegi var)
- Respawn (DB test isolation)
- EF Core InMemory provider ONERILMEZ (iliskisel kisitlamalari uygulamaz, Microsoft da karsi)

---

## Health Check

```csharp
services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddRedis(redisConnectionString)
    .AddCheck("custom", () => HealthCheckResult.Healthy());

app.MapHealthChecks("/health/live", new() { Predicate = _ => false });
app.MapHealthChecks("/health/ready");
```

---

## OpenTelemetry

```csharp
// Program.cs
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddEntityFrameworkCoreInstrumentation()
        .AddOtlpExporter());

// appsettings.json
// "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317"
// "OTEL_SERVICE_NAME": "my-api"
```

Paketler: `OpenTelemetry.Extensions.Hosting`, `OpenTelemetry.Instrumentation.AspNetCore`, `OpenTelemetry.Exporter.OpenTelemetryProtocol`

---

## Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
USER app
ENTRYPOINT ["dotnet", "MyApp.dll"]
```


═══════════════════════════════════════════════════════════════
=== FILE: stack/nodejs.md ===
Boyut: 9.3 KB | Son değişiklik: 2026-02-16
═══════════════════════════════════════════════════════════════

# NODE.JS / EXPRESS STACK REFERANSI

## Tespit
- `package.json` + `express` veya `fastify` dependency -> bu stack aktif

---

## Teknoloji Tablosu

| Katman | Arac |
|--------|------|
| Framework | Express.js (veya Fastify, NestJS) |
| ORM | Prisma |
| Validation | Zod |
| Auth | jose (onerilen) veya jsonwebtoken (legacy). jose: Web Crypto, Edge uyumlu, JWK/JWKS destegi |
| Password | argon2 (argon2id, onerilen) veya bcryptjs (pure JS, native binding sorunu yok) |
| Logging | Pino (onerilen, 2-5x hizli) veya Winston |
| Cache | ioredis |
| Test | Vitest (onerilen, TS native, 5-20x hizli) veya Jest + Supertest |
| API Docs | swagger-jsdoc + swagger-ui-express |
| Security | Helmet + cors |
| Rate Limit | express-rate-limit |

---

## Middleware Sirasi

```javascript
app.use(helmet());                    // 1. Security headers
app.use(cors(corsOptions));           // 2. CORS
app.use(express.json({ limit: '10mb' })); // 3. Body parser
app.use(requestLogger);              // 4. Request logging
app.use(rateLimiter);                // 5. Rate limiting
app.use('/api/v1', routes);          // 6. Routes
app.use(errorHandler);               // 7. Global error handler (EN SON)
```

Sira ONEMLIDIR. Error handler her zaman en sonda.

---

## Proje Yapisi

```
src/
├── config/          # Environment, DB, logger config
├── controllers/     # Route handler'lar (sadece HTTP concern)
├── services/        # Is mantigi
├── repositories/    # Veri erisimi (opsiyonel, Prisma direkt service'te de olabilir)
├── routes/          # Express route tanimlari
├── middlewares/     # Auth, error handler, rate limit, validation
├── validators/      # Zod schemalari
├── types/           # TypeScript interface/type tanimlari
├── utils/           # Helper fonksiyonlar (JWT, password, errors)
├── prisma/          # Prisma schema ve migration'lar
└── scripts/         # Seed, migration script'leri
```

---

## Prisma Kaliplari

### Schema
```prisma
model User {
  // NOT: Prisma uuid() UUID v4 uretir. UUID v7 icin uygulama katmaninda uret
  // veya DB fonksiyonu kullan: @default(dbgenerated("gen_random_uuid_v7()"))
  id        String   @id @default(uuid())
  email     String   @unique
  password  String
  role      Role     @default(USER)
  isActive  Boolean  @default(true) @map("is_active")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")

  @@map("users")
}
```

### Zorunlu Kurallar
- `@map()` ile camelCase -> snake_case donusumu
- `@@map()` ile tablo adi snake_case, cogul
- `@default(uuid())` PK icin (UUID v4 uretir — UUID v7 gerekiyorsa bkz. schema ornegi ustundeki not)
- `findMany` -> pagination ile (`skip`, `take`)
- `select` -> sadece gerekli alanlar
- `include` -> N+1 onleme (iliski yuklemesi)

### Migration
```bash
npx prisma migrate dev --name {isim_aciklayici}
npx prisma generate
```

---

## Zod Validation

```typescript
const createUserSchema = z.object({
  email: z.string().email('Gecerli bir email giriniz').max(255),
  password: z.string()
    .min(8, 'En az 8 karakter')
    .regex(/[A-Z]/, 'En az bir buyuk harf')
    .regex(/[a-z]/, 'En az bir kucuk harf')
    .regex(/[0-9]/, 'En az bir rakam')
    .regex(/[^a-zA-Z0-9]/, 'En az bir ozel karakter'),
});

// Middleware olarak kullanim
const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse(req.body);
  if (!result.success) return res.status(422).json({ /* hata */ });
  req.validated = result.data;
  next();
};
```

---

## Logging

### Pino (Onerilen — 2-5x hizli, JSON native)
```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV !== 'production'
    ? { target: 'pino-pretty' }
    : undefined,
});

// Correlation ID middleware (pino-http ile)
import pinoHttp from 'pino-http';
app.use(pinoHttp({
  logger,
  genReqId: (req) => req.headers['x-correlation-id'] || uuidv4(),
}));
```

### Winston (Alternatif)
```typescript
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'api' },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
  ],
});
```

---

## Authentication (JWT)

```typescript
// Onerilen: jose (modern, standart uyumlu)
import * as jose from 'jose';

const privateKey = await jose.importPKCS8(privateKeyPem, 'RS256');
const publicKey = await jose.importSPKI(publicKeyPem, 'RS256');

// Token olusturma
const accessToken = await new jose.SignJWT({ email: user.email, role: user.role })
  .setProtectedHeader({ alg: 'RS256' })
  .setSubject(user.id)
  .setIssuedAt()
  .setIssuer('your-api')
  .setAudience('your-app')
  .setExpirationTime('1h')
  .sign(privateKey);

// Token dogrulama
const { payload } = await jose.jwtVerify(token, publicKey, {
  issuer: 'your-api',
  audience: 'your-app',
});
```

Password hashing (bkz. `guvenlik/CLAUDE.md` — argon2id onerilen):
```typescript
// Onerilen: argon2
import argon2 from 'argon2';
const hash = await argon2.hash(password, { type: argon2.argon2id });
const isValid = await argon2.verify(hash, password);

// Kabul edilir: bcryptjs (pure JS, native binding sorunu yok)
import bcrypt from 'bcryptjs';
const hash = await bcrypt.hash(password, 12);
const isValid = await bcrypt.compare(password, hash);
```

---

## Error Handling

```typescript
// Custom error class
class AppError extends Error {
  constructor(public statusCode: number, public code: string, message: string) {
    super(message);
  }
}

// Global error handler (EN SON middleware)
const errorHandler = (err, req, res, next) => {
  logger.error({ err, correlationId: req.correlationId });

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
      requestId: req.correlationId,
    });
  }

  // Beklenmeyen hata -> detay gizle
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'Bir hata olustu' },
    requestId: req.correlationId,
  });
};
```

---

## Test

### Unit Test (Vitest — Onerilen)
```typescript
import { describe, it, expect, vi } from 'vitest';

describe('UserService', () => {
  it('should throw NotFoundError when user does not exist', async () => {
    const mockRepo = { findById: vi.fn().mockResolvedValue(null) };
    const service = new UserService(mockRepo);

    await expect(service.getById('fake-id')).rejects.toThrow(NotFoundError);
  });
});
```

### Integration Test (Supertest)
```typescript
import { describe, it, expect } from 'vitest';

describe('GET /api/v1/users', () => {
  it('should return 200 with user list', async () => {
    const res = await request(app).get('/api/v1/users');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });
});
```

Not: Jest'ten Vitest'e gecis minimum — `jest.fn()` -> `vi.fn()`, config `vitest.config.ts` dosyasinda.

---

## TypeScript Kurallari

- `strict: true` -> tsconfig.json'da ZORUNLU
- `any` kullanimi YASAK (eslint rule ile engelle)
- Interface kullan (DTO'lar, service contractlar)
- Type kullan (union, utility types)
- `as` type assertion minimumda tut
- ESM tercih et (`"type": "module"` in package.json) — CommonJS legacy projelerde kabul edilir
- Import extension'lari: ESM'de `.js` extension zorunlu olabilir (tsconfig `moduleResolution` ayarina dikkat)

---

## Health Check

```typescript
// Basit health endpoint
app.get('/health/live', (req, res) => res.json({ status: 'ok' }));

app.get('/health/ready', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`; // DB kontrol
    // await redis.ping();            // Redis kontrol (varsa)
    res.json({ status: 'ready' });
  } catch (err) {
    res.status(503).json({ status: 'not ready', error: err.message });
  }
});
```

---

## OpenTelemetry

```typescript
// tracing.ts — uygulama baslamadan ONCE import edilmeli
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: process.env.OTEL_SERVICE_NAME || 'my-api',
});
sdk.start();
```

Paketler: `@opentelemetry/sdk-node`, `@opentelemetry/auto-instrumentations-node`, `@opentelemetry/exporter-trace-otlp-http`

---

## Docker

```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate && npm run build

FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
ENV NODE_ENV=production
USER node
CMD ["node", "dist/index.js"]
```


═══════════════════════════════════════════════════════════════
=== FILE: stack/laravel.md ===
Boyut: 11.2 KB | Son değişiklik: 2026-02-16
═══════════════════════════════════════════════════════════════

# LARAVEL / PHP STACK REFERANSI

## Tespit
- `composer.json` + `laravel/framework` dependency -> bu stack aktif

---

## Teknoloji Tablosu

| Katman | Arac |
|--------|------|
| Framework | Laravel 11+ |
| ORM | Eloquent |
| Validation | Form Request |
| Auth | Laravel Sanctum (SPA/Mobile) veya Passport (OAuth2) |
| Password | Hash facade (argon2id onerilen, bcrypt kabul edilir) |
| Logging | Laravel Log (Monolog) |
| Cache | predis / phpredis |
| Test | PHPUnit veya Pest |
| API Docs | Scramble (dedoc/scramble, onerilen — otomatik) veya L5-Swagger |
| Rate Limit | Laravel built-in (ThrottleRequests middleware) |
| Queue | Laravel Queue (Redis/SQS/Database) |

---

## Middleware Sirasi

`bootstrap/app.php` (Laravel 11+ — Kernel.php kaldirildi):

```
api middleware group:
1. throttle:api          // Rate limiting
2. SubstituteBindings    // Route model binding
3. (custom auth middleware)
4. (custom logging middleware)
```

Global middleware:
- TrustProxies
- HandleCors
- PreventRequestsDuringMaintenance
- ValidatePostSize
- TrimStrings

---

## Proje Yapisi

```
app/
├── Http/
│   ├── Controllers/     # API Controller'lar
│   ├── Requests/        # Form Request (validation)
│   ├── Resources/       # API Resource (DTO/transformer)
│   └── Middleware/       # Custom middleware
├── Models/              # Eloquent model'ler
├── Services/            # Is mantigi (Controller'da olmamali)
├── Repositories/        # Veri erisimi (opsiyonel, Eloquent direkt Service'te de olabilir)
├── Policies/            # Authorization policy'leri
├── Exceptions/          # Custom exception'lar
├── Observers/           # Model observer'lar
└── Providers/           # Service Provider'lar (DI kayitlari)

database/
├── migrations/          # DB migration'lar
├── seeders/             # Seed data
└── factories/           # Test factory'ler

routes/
└── api.php              # API route tanimlari

tests/
├── Unit/                # Unit testler
└── Feature/             # Integration/Feature testler
```

---

## Eloquent Kaliplari

### Model
```php
class User extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
    // Laravel 11+: method-based casts (property-based deprecated)
    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime'];
    }

    // Iliski
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
```

### Zorunlu Kurallar
- `$fillable` ZORUNLU (mass assignment korunmasi)
- `$hidden` ile hassas alanlar response'dan gizle
- `$casts` ile tip donusumleri acikca belirt
- `SoftDeletes` trait -> soft delete gerekiyorsa
- Scope kullan: `scopeActive($query)` -> `User::active()->get()`
- `select()` -> sadece gerekli alanlar
- `with()` -> N+1 onleme (eager loading)

### Migration
```bash
php artisan make:migration create_users_table
php artisan migrate
php artisan migrate:rollback
```

`down()` metodu ASLA bos birakilmaz.

---

## Form Request Validation

```php
class CreateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // veya policy kontrolu
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'max:255', 'unique:users'],
            'password' => [
                'required', 'min:8',
                'regex:/[A-Z]/',  // buyuk harf
                'regex:/[a-z]/',  // kucuk harf
                'regex:/[0-9]/',  // rakam
                'regex:/[^a-zA-Z0-9]/',  // ozel karakter
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email alani zorunludur',
            'password.min' => 'Sifre en az 8 karakter olmali',
        ];
    }
}
```

---

## API Resource (DTO)

```php
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'createdAt' => $this->created_at->toISOString(),
        ];
        // password, remember_token ASLA donmez
    }
}

// Kullanim
return UserResource::collection($users);
return new UserResource($user);
```

---

## Logging

```php
// config/logging.php -> stack channel
Log::info('User created', ['userId' => $user->id]);
Log::error('Payment failed', ['orderId' => $order->id, 'error' => $e->getMessage()]);
```

Correlation ID middleware:
```php
public function handle(Request $request, Closure $next)
{
    $correlationId = $request->header('X-Correlation-Id', Str::uuid()->toString());
    Log::withContext(['correlationId' => $correlationId]);
    $response = $next($request);
    return $response->header('X-Correlation-Id', $correlationId);
}
```

**YASAK:** `Log::info('Login', ['password' => $password])` -> hassas veri loglanmaz

---

## Authentication (Sanctum)

```php
// API token olusturma
$token = $user->createToken('api-token')->plainTextToken;

// Route korumasi
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
});

// Token iptal
$request->user()->currentAccessToken()->delete(); // logout
$request->user()->tokens()->delete(); // tum session'lar
```

Password hashing (bkz. `guvenlik/CLAUDE.md` — argon2id onerilen):
```php
// config/hashing.php -> driver'i degistir:
// 'driver' => 'argon2id',  // onerilen (OWASP 2024)
// 'driver' => 'bcrypt',    // kabul edilir (varsayilan)

// argon2id (onerilen):
$hash = Hash::make($password); // config'den argon2id kullanir
// veya acikca:
$hash = Hash::make($password, [
    'memory' => 19456,  // KiB (OWASP minimum)
    'time' => 2,        // iterations
    'threads' => 1,     // parallelism
]);
$isValid = Hash::check($password, $hash);

// bcrypt (kabul edilir):
// config/hashing.php -> 'bcrypt' => ['rounds' => 12]
$hash = Hash::make($password); // bcrypt, 12 rounds
```

### JWT Kullanilacaksa
- Laravel Passport (OAuth2 grant'leri ile JWT)
- veya `php-open-source-saver/jwt-auth` (maintained fork)
- **tymon/jwt-auth KULLANMA** — bakimsiz, PHP 8.2+ uyumluluk sorunlari, guvenlik aciklari

```php
// Passport veya jwt-auth config
// Access token: 1 saat, Refresh token: 14 gun
```

---

## Authorization (Policy)

```php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->user_id;
    }

    public function delete(User $user, Order $order): bool
    {
        return $user->hasRole('admin');
    }
}

// Controller'da
$this->authorize('view', $order);
// veya
Gate::authorize('delete', $order);
```

---

## Error Handling

```php
// app/Exceptions/Handler.php veya bootstrap/app.php (Laravel 11+)
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (NotFoundHttpException $e, Request $request) {
        if ($request->is('api/*')) {
            return response()->json([
                'success' => false,
                'error' => ['code' => 'NOT_FOUND', 'message' => 'Kaynak bulunamadi'],
            ], 404);
        }
    });
})
```

---

## Test

### Unit Test (Pest)
```php
test('user service throws not found when user missing', function () {
    $repo = Mockery::mock(UserRepository::class);
    $repo->shouldReceive('findById')->andReturnNull();
    $service = new UserService($repo);

    expect(fn() => $service->getById('fake-id'))->toThrow(ModelNotFoundException::class);
});
```

### Feature Test (HTTP)
```php
test('GET /api/v1/users returns 200', function () {
    $response = $this->getJson('/api/v1/users');

    $response->assertStatus(200)
        ->assertJsonStructure(['success', 'data']);
});
```

### Factory & Seeder
```php
User::factory()->count(10)->create(); // Test icin fake data
```

---

## Rate Limiting

```php
// bootstrap/app.php veya RouteServiceProvider
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});
```

---

## Service Provider (DI)

```php
class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->singleton(PaymentGateway::class, StripePaymentGateway::class);
    }
}
```

---

## Artisan Komutlari

```bash
php artisan make:model User -mfsc   # Model + Migration + Seeder + Controller
php artisan make:request CreateUserRequest
php artisan make:resource UserResource
php artisan make:policy UserPolicy --model=User
php artisan make:test UserTest --unit
php artisan serve                     # Dev server
php artisan route:list               # Route listesi
php artisan optimize                 # Production cache
```

---

## Docker

```dockerfile
FROM php:8.3-fpm-alpine AS base
RUN docker-php-ext-install pdo pdo_pgsql

FROM base AS build
WORKDIR /app
COPY composer.* ./
RUN composer install --no-dev --optimize-autoloader
COPY . .

FROM base
WORKDIR /app
COPY --from=build /app .
USER www-data
CMD ["php-fpm"]
```

Nginx reverse proxy ornegi:
```nginx
server {
    listen 80;
    server_name api.example.com;
    root /app/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

---

## Laravel Octane (Performans)

Octane, uygulamayi bellekte tutarak her istekte framework'u yeniden baslatmaz.
10x'e kadar performans artisi saglar.

```bash
composer require laravel/octane
php artisan octane:install  # Swoole, RoadRunner veya FrankenPHP
php artisan octane:start
```

**Dikkat:** Singleton'lar request'ler arasi paylasiliyor — state leak'e dikkat et.
`$this->app->scoped()` kullan, static state'den kacin.

---

## Health Check

```php
// routes/api.php
Route::get('/health/live', fn() => response()->json(['status' => 'ok']));

Route::get('/health/ready', function () {
    try {
        DB::select('SELECT 1');
        // Redis::ping(); // varsa
        return response()->json(['status' => 'ready']);
    } catch (\Throwable $e) {
        return response()->json(['status' => 'not ready'], 503);
    }
});
```

---

## OpenTelemetry

```bash
composer require open-telemetry/sdk open-telemetry/exporter-otlp
composer require open-telemetry/opentelemetry-auto-laravel
```

```php
// .env
OTEL_PHP_AUTOLOAD_ENABLED=true
OTEL_SERVICE_NAME=my-api
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_TRACES_EXPORTER=otlp
```

`opentelemetry-auto-laravel` paketi otomatik instrumentation saglar (HTTP, DB, Redis).


# ════════════════════════════════════════════════════════════
# BÖLÜM B: SÜREÇ DOSYALARI (surec/)
# CLAUDE.md tarafından referans verilir, otomatik yüklenmez
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: surec/proje-kesfi.md ===
Boyut: 2.1 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# PROJE KESFI & STACK TESPITI

Bu dosya yeni projeye girildiginde veya proje dosyasi yoksa kullanilir.
Ana CLAUDE.md'den referans verilir, her konusmada otomatik yuklenmez.

---

## Stack Tespiti (Otomatik)

Projeye girildiginde aktif stack tespit edilir:

| Sinyal | Stack | Dosya |
|--------|-------|-------|
| `*.csproj` / `*.sln` | .NET | `backend-governance/stack/dotnet.md` |
| `package.json` + Express/Fastify | Node.js | `backend-governance/stack/nodejs.md` |
| `composer.json` + Laravel | Laravel | `backend-governance/stack/laravel.md` |

Stack dosyasi tespit sonrasi okunur (otomatik yuklenmez).

---

## Otomatik Proje Kesfi

Ilk Adim'da aktif proje dosyasi yoksa, Team Lead projeyi tarar ve `proje/` klasorune dosya olusturur.

### Otomatik Tespit Edilenler (tarama ile)

| Alan | Nereden |
|------|---------|
| Proje adi | Kok klasor adi, package.json `name`, *.csproj AssemblyName |
| Stack | Ilk Adim'da zaten tespit ediliyor |
| DB | Config dosyalari: appsettings.json, .env, prisma/schema.prisma, config/database.php |
| Durum | git log var → devam / git yok → yeni |
| Cache | Dependency'lerde Redis paketi var mi (StackExchange.Redis, ioredis, predis) |
| CI/CD | `.github/workflows/` → GitHub Actions, `azure-pipelines.yml` → Azure DevOps |
| Auth yaklasimi | JWT paketi, Sanctum, Passport vb. dependency'lerden |
| Mevcut yapilar | Klasor yapisi (Controllers/, Services/, migrations/ vb.) |

### Kullaniciya Sorulanlar (otomatik tespit edilemez)

- **Domain:** Projenin alani (e-ticaret, fintech, SaaS, vb.)
- **Kritik akislar:** Hangi is akislari harden mode tetiklemeli?
- **Bilinen kisitlamalar:** Legacy entegrasyon, hosting limitleri, vb.
- **Domain-spesifik kurallar:** Sektore ozel kurallar

### Akis

```
1. Projeyi tara (dosyalar, config, dependency, git)
2. Tespit edilenleri doldur (Kimlik + Ortam tablolari)
3. Kullaniciya sor: domain, kritik akislar, kisitlamalar
4. proje/{proje-adi}.md olustur
5. proje/CLAUDE.md'de aktif proje olarak isaretle
```

Not: Kullanici "bilmiyorum" veya "sonra" derse, bos birak — ilerledikce tamamlanir.


═══════════════════════════════════════════════════════════════
=== FILE: surec/deployment.md ===
Boyut: 1.3 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# DEPLOYMENT REHBERI

Governance framework'unun yeni projeye kurulumu.
Ana CLAUDE.md'den referans verilir, her konusmada otomatik yuklenmez.

---

## Yontem 1: Subagent'larla (Onerilen)

```
my-project/
├── CLAUDE.md                         ← ana governance dosyasinin icerigi
├── .claude/
│   └── agents/                       ← backend-governance/.claude/agents/ kopyala
│       ├── backend-developer.md
│       ├── security-reviewer.md
│       ├── quality-gate.md
│       ├── qa-engineer.md            ← uygulama ayaga kalktiktan sonra aktif
│       ├── architect.md
│       └── devops.md
├── backend-governance/               ← governance dosyalari
│   ├── api/CLAUDE.md
│   ├── guvenlik/CLAUDE.md
│   ├── stack/laravel.md
│   └── ...
└── app/
```

Farkli klasor adi kullanilirsa: bu dosya + 5 subagent dosyasindaki yollar guncellenir.

---

## Yontem 2: Subagent'siz (Basit)

Subagent kullanmak istemiyorsan, tum governance dosyalarini `@` ile import et:
```
@backend-governance/backend/CLAUDE.md
@backend-governance/api/CLAUDE.md
@backend-governance/guvenlik/CLAUDE.md
... (tum dosyalar)
```
Not: Bu ~1700 satir baslangicta yukler. Basit ama context agir olur.


# ════════════════════════════════════════════════════════════
# BÖLÜM C: PROJE PROFİLLERİ (proje/)
# CLAUDE.md: aktif proje işaretçisi
# SABLON.md: boş şablon — yeni proje eklenince kopyalanır
# memory-box.md: doldurulmuş örnek (.NET 9 + MySQL)
# ════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
=== FILE: proje/CLAUDE.md ===
Boyut: 1.4 KB | Son değişiklik: 2026-03-21
═══════════════════════════════════════════════════════════════

# PROJE-SPESIFIK KURALLAR

## Nasil Calisir

Bu klasor, her proje icin ozel kurallar icerir.
Governance kurallari genel ve stack-bagimsizdir — proje dosyalari ise o projeye ozel kararlari, kisitlamalari ve domain kurallarini tanimlar.

## Proje Dosyasi Olusturma

1. `SABLON.md` dosyasini kopyala: `cp SABLON.md my-project.md`
2. Tum alanlari doldur (Kimlik, Domain Kurallari, Kararlar, Kisitlamalar, Kritik Akislar, Ortam)
3. Asagidaki "Aktif Proje" bolumune dosya adini yaz

## Aktif Proje

Bu klasor artik sadece SABLON icerir.
Aktif projeler kendi dizinlerinde yasarlar (ornek: `../memory-box/proje/`).
Her proje kendi `proje/CLAUDE.md` dosyasinda aktif projeyi isaret eder.

Mevcut projeler:
- **memory-box/** — AniKutusu (.NET 9)
- **sales-app-api/** — Restoran Buyume Koclugu / Gorev Oneri Motoru (.NET 9)
- **visa-app/** — VESIQA / AI Destekli Vize Fotograf Platformu (Laravel 12)

## Proje Dosyasi Ne Icerir

| Bolum | Icerik |
|-------|--------|
| Kimlik | Proje adi, domain, stack, DB, durum |
| Domain Kurallari | Sektore ozel kurallar (e-ticaret, fintech, SaaS, vb.) |
| Proje-Spesifik ADR | Bu projeye ozel mimari kararlar |
| Bilinen Kisitlamalar | Teknik/is kisitlari (legacy entegrasyon, hosting, vb.) |
| Kritik Akislar | harden mode'u otomatik tetikleyen akislar |
| Ortam Bilgisi | Dev/staging/prod URL, DB turu, CI/CD |


═══════════════════════════════════════════════════════════════
=== FILE: proje/SABLON.md ===
Boyut: 3.4 KB | Son değişiklik: 2026-02-16
═══════════════════════════════════════════════════════════════

# PROJE: {Proje Adi}

> Bu dosya yeni bir projede ilk calisma basladiginda otomatik olusturulur.
> Team Lead projeyi tarar, tespit edebildiklerini doldurur, geri kalanini kullaniciya sorar.
> Doldurulan dosya o projenin CLAUDE.md'si gibi davranir — tum governance
> kurallari + bu dosyadaki proje-spesifik kurallar birlikte gecerli olur.

---

## Kimlik

> Otomatik: Proje adi, Stack, DB, Durum — proje taranarak doldurulur.
> Kullaniciya sorulur: Domain.

| Alan | Deger | Kaynak |
|------|-------|--------|
| Proje adi | {ornek: TrendwayTravel Poland} | otomatik |
| Domain | {ornek: seyahat, e-ticaret, fintech, SaaS} | kullaniciya sor |
| Stack | {ornek: .NET, Node.js, Laravel} | otomatik |
| DB | {ornek: PostgreSQL, SQL Server, MySQL} | otomatik |
| Durum | {ornek: yeni / devam / bakim / migration} | otomatik |

---

## Domain-Spesifik Kurallar

> Kullaniciya sorulur. Domain belirlendikten sonra asagidaki orneklerden ilgili olanlar secilir,
> gerekirse yenileri eklenir. Kullanici "sonra" derse bos birakilir.

### E-Ticaret ise:
- Fiyat hesaplamalarinda DECIMAL kullan, FLOAT ASLA
- Stok azaltma idempotent olmali (ayni siparis 2 kez stok dusmemeli)
- Odeme islemi basarisiz olursa siparis durumu tutarli kalmali
- Kupon/indirim hesabi server-side, client'a guvenme

### Fintech / Odeme ise:
- Tum parasal islemler transaction icinde
- Audit log zorunlu (kim, ne zaman, ne yapti)
- PCI-DSS uyumlulugu kontrolu
- Idempotency key zorunlu (her odeme isteginde)

### SaaS / Multi-tenant ise:
- Tenant isolation: her sorguda tenant filtresi zorunlu
- Tenant ID middleware'de set edilir, manual gecilmez
- Cross-tenant veri sizintisi testi zorunlu
- Rate limiting tenant bazli

### API Gateway / Public API ise:
- Versiyonlama stratejisi kararli (URL vs header)
- Breaking change = major version artisi
- Deprecation sureci tanimli (min 3 ay uyari)
- API key yonetimi ve throttling

---

## Proje-Spesifik Kararlar (ADR)

> Projeye ozel alinan kararlar buraya yazilir.

| # | Karar | Tarih | Neden |
|---|-------|-------|-------|
| 1 | {ornek: Response formati: Envelope pattern} | {tarih} | {Frontend ekibi tutarli format istiyor} |
| 2 | {ornek: PK: UUID (auto-increment degil)} | {tarih} | {Distributed sistem plani var} |
| 3 | ... | ... | ... |

---

## Bilinen Kisitlamalar

> Kullaniciya sorulur. Projenin teknik veya is kisitlari.

- {ornek: Legacy SOAP servisi ile entegrasyon zorunlu}
- {ornek: Hosting: shared hosting, Docker yok}
- {ornek: Ucuncu parti API rate limiti: 100 istek/dk}
- {ornek: iOS App Store review sureci 2 hafta}

---

## Kritik Akislar

> Kullaniciya sorulur. Bu projedeki en riskli / en onemli is akislari.
> Bunlar icin harden mode otomatik aktif olur.

1. {ornek: Odeme akisi (siparis -> odeme -> onay -> stok dusme)}
2. {ornek: Kullanici kayit + email dogrulama}
3. {ornek: Veri migration'i (eski sistemden yeni sisteme)}

---

## Ortam Bilgisi

> Otomatik: Config dosyalari, dependency ve CI/CD dosyalarindan tespit edilir.

| Ortam | URL / Bilgi | Kaynak |
|-------|-------------|--------|
| Development | {localhost:5000 veya bos} | otomatik |
| Staging | {staging.example.com veya bos} | otomatik / kullaniciya sor |
| Production | {api.example.com veya bos} | otomatik / kullaniciya sor |
| DB | {connection bilgisi yerine sadece tur: PostgreSQL 15} | otomatik |
| Cache | {Redis / yok} | otomatik |
| CI/CD | {GitHub Actions / Azure DevOps / yok} | otomatik |


═══════════════════════════════════════════════════════════════
=== FILE: proje/memory-box.md ===
Boyut: 5.7 KB | Son değişiklik: 2026-02-16
═══════════════════════════════════════════════════════════════

# PROJE: AniKutusu (Memory Box)

> Otomatik proje kesfi ile olusturuldu. Tarih: 2026-02-16

---

## Kimlik

| Alan | Deger | Kaynak |
|------|-------|--------|
| Proje adi | AniKutusu (Memory Box) | otomatik |
| Domain | Etkinlik Fotograf/Video Paylasim Platformu | kullaniciya soruldu |
| Stack | .NET 9, ASP.NET Core Web API, Clean Architecture | otomatik |
| DB | MySQL 8.0+ (EF Core 9, Pomelo, Code-First) | otomatik |
| Durum | devam (28+ commit, aktif gelistirme) | otomatik |

---

## Ortam Bilgisi

| Ortam | URL / Bilgi | Kaynak |
|-------|-------------|--------|
| Development | http://localhost:5212 | otomatik |
| Staging | — | — |
| Production | — | — |
| DB | MySQL 8.0+ (Pomelo EF Core, connection pool: 5-20) | otomatik |
| Cache | In-Memory (IMemoryCache) — Redis yok | otomatik |
| CI/CD | GitHub Actions (ci.yml: build + test, main/develop) | otomatik |
| Background Jobs | Hangfire (MySQL storage) | otomatik |
| Storage | Local filesystem (uploads/) — Cloud gecisi planli | otomatik + kullanici |
| SMS Provider | Netgsm (Turkiye) | otomatik |
| Logging | Serilog (Console + File) | otomatik |

---

## Teknoloji Detaylari

### Auth
- **JWT**: HS256, 60dk token, Issuer/Audience: "AniKutusu"
- **Google OAuth 2.0**: ID Token validation, otomatik kullanici olusturma
- **Password**: Bcrypt hashing
- **Roller**: Customer (default), Admin

### Rate Limiting
| Policy | Limit |
|--------|-------|
| Global | 100 req/dk per user |
| Auth | 10 req/dk per IP |
| SMS | 5 req/5dk per IP |
| Upload | 20 req/dk per IP |
| Gallery | 30 req/dk per IP |
| Download | 5 req/5dk per IP |

### Upload
- Max request body: 2GB
- Request timeout: 10dk
- HEIC → JPEG otomatik donusum (Magick.NET)
- Thumbnail olusturma (ImageSharp)

---

## Mimari Yapi

```
src/
├── AniKutusu.Domain/           # Entities, ValueObjects (bagimsiz katman)
├── AniKutusu.Application/      # Services, Validators, Interfaces
├── AniKutusu.Infrastructure/   # EF Core, Repositories, JWT, Hangfire, Storage
└── AniKutusu.Api/              # Controllers (12), Middleware (4), Program.cs
```

### Domain Entities
- **User** — GUID ID, Email, PasswordHash, GoogleId, Role, Language
- **Event** — GUID ID, UserId, Title, EventDate, EventType, Password, SoftDelete
- **Media** — GUID ID, EventId, FileUrl, FileType, ThumbnailUrl, Note, SoftDelete
- **ShareableLink** — GUID ID, EventId, Token (256-bit), ExpiresAt, ViewCount
- **SmsVerification** — GUID ID, PhoneNumberHash, Code (6-digit), 3dk expiry, 3 max attempt

### Controllers (12)
AuthController, GoogleAuthController, EventsController, MediaController, UploadController, GalleryController, ShareableLinksController, ExportController, ProfileController, SmsController, FilesController + HealthChecks

### Middleware
GlobalExceptionMiddleware, CorrelationIdMiddleware, PerformanceMiddleware, SecurityHeadersMiddleware

---

## Domain-Spesifik Kurallar

### Etkinlik/Fotograf Paylasim:
- Misafir yukleme SMS dogrulamasi ile korunur (maliyet + spam kontrolu)
- Etkinlik sifre korumalari server-side dogrulanir
- Shareable link token'lari 256-bit guvenli (tahmin edilemez)
- Telefon numaralari hash'lenerek saklanir (privacy)
- HEIC dosyalar otomatik JPEG'e donusturulur (iPhone uyumlulugu)
- Soft delete kullanilir (geri alma imkani, kalici silme yok)
- Export dosyalari 7 gun sonra temizlenir (disk yonetimi)

---

## Proje-Spesifik Kararlar (ADR)

| # | Karar | Tarih | Neden |
|---|-------|-------|-------|
| 1 | PK: GUID (auto-increment degil) | 2025-09 | Distributed sistem esnekligi, URL guvenlik |
| 2 | Direct Service Pattern (MediatR/CQRS degil) | 2025-09 | YAGNI — proje boyutu icin yeterli |
| 3 | Exception-based error handling (Result Pattern degil) | 2025-09 | Basitlik — mevcut middleware ile yeterli |
| 4 | Local file storage | 2025-09 | Baslangic icin yeterli — cloud gecisi planli |
| 5 | Bcrypt (Argon2id degil) | 2025-09 | .NET ekosisteminde yaygin, yeterli guvenlik |
| 6 | HS256 JWT (RS256 degil) | 2025-09 | Tek sunucu, asymmetric key gereksiz |
| 7 | Hangfire (background jobs) | 2025-10 | ZIP export, cleanup gibi uzun isler icin |
| 8 | Netgsm SMS provider | 2025-10 | Turkiye odakli, yerel numara destegi |

---

## Bilinen Kisitlamalar

- **Local storage** — Dosyalar sunucu diskinde, cloud gecisi planli (S3/Azure Blob)
- **MySQL only** — Pomelo provider hardcoded, DB degisimi kolay degil
- **Turkiye odakli SMS** — Netgsm sadece Turkiye'de calisir
- **Docker yok** — Dockerfile/docker-compose henuz eklenmedi
- **Monitoring yok** — APM entegrasyonu (App Insights, Sentry) yok
- **Test coverage bilinmiyor** — Testler var ama coverage raporu yok

---

## Kritik Akislar

> Kullanici "bilmiyorum" dedi — taramaya dayanarak belirlenen oneriler:

1. **Auth akisi** — Kayit, login, Google OAuth, JWT token uretimi
2. **Misafir upload akisi** — SMS dogrulama → token → dosya yukleme (maliyet riski)
3. **Shareable link erisimi** — AllowAnonymous, token dogrulama, veri erisimi
4. **DB migration** — Schema degisiklikleri, veri butunlugu

> Bu akislarda calisirken harden mode otomatik aktif olur.

---

## Production Readiness

| Ozellik | Durum |
|---------|-------|
| Structured logging (Serilog) | OK |
| Global exception handling | OK |
| Health checks (MySQL + app) | OK |
| Rate limiting (5 policy) | OK |
| CORS | OK |
| HTTPS redirect | OK |
| JWT authentication | OK |
| Background jobs (Hangfire) | OK |
| Connection pooling | OK |
| Response compression | OK |
| Correlation ID | OK |
| Performance middleware | OK |
| Security headers | OK |
| Dockerfile | EKSIK |
| Cloud storage | PLANLI |
| APM/Monitoring | EKSIK |
| Test coverage raporu | EKSIK |

