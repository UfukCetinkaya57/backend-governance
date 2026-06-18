# Claude Code'u Tek Başına Kullanmayı Bıraktım — Artık O Benim Team Lead'im

## Sorun: AI Kod Yazıyor, Ama Kim Kontrol Ediyor?

Claude Code'a "şu endpoint'i yaz" diyorsun, yazıyor. "Şu bug'ı düzelt" diyorsun, düzeltiyor. Hızlı, etkili, etkileyici.

Ama bir süre sonra fark ediyorsun:

- Güvenlik kontrolünü **sen** yapıyorsun (ya da unutuyorsun)
- Kod kalitesini **sen** değerlendiriyorsun (ya da "çalışıyor, tamam" diyorsun)
- Mimari kararları **sen** takip ediyorsun (ya da her seferinde farklı bir pattern çıkıyor)
- Auth endpoint'ine injection açığı girmiş mi? **Sen** bakacaksın

Kısacası Claude hızlı bir junior developer gibi çalışıyor — ne dersen yapıyor ama kimse arkasından kontrol etmiyor. Gerçek bir takımda bu kabul edilemez. Peki neden AI ile çalışırken kabul ediyoruz?

---

## Soru: Ya Claude Kendini Kontrol Edebilseydi?

Bu soruyu kendime sordum ve cevabı inşa ettim.

Claude Code'un sub-agent özelliğini keşfettiğimde bir şey fark ettim: Claude'a sadece "kod yaz" demek yerine, onu bir **Team Lead** gibi çalıştırabilirdim. Kodu kendisi yazmak yerine, uzman agent'lara delege edebilir, sonuçları kontrol edebilir ve bana rapor verebilirdi.

Ortaya çıkan şey: **claude-code-governance** — Claude Code'u yapılandırılmış bir mühendislik takımına dönüştüren açık kaynak bir governance framework'ü.

---

## Nasıl Çalışıyor?

Framework'ü projenize eklediğinizde Claude artık genel amaçlı bir asistan olarak çalışmıyor. Tanımlanmış bir rolü var: **görevi anla, doğru pipeline'ı seç, doğru agent'a delege et, çıktıyı doğrula.**

### 5 Uzman Agent

Her biri farklı bir uzmanlık alanına sahip:

- **backend-developer** — Kodu yazan agent. Endpoint, service, migration, validation.
- **security-reviewer** — Güvenlik taraması yapan agent. Auth, injection, CORS, brute force.
- **quality-gate** — 11 noktalık kalite kontrol listesiyle kodu değerlendiren agent.
- **architect** — Mimari kararları, YAGNI ihlallerini ve gereksiz karmaşıklığı yakalayan agent.
- **devops** — Deployment, Docker, monitoring, logging işlerini yöneten agent.

### 3 Kademeli Pipeline

Her görev aynı ağırlıkta değil. Bir config değişikliği ile bir auth sistemi aynı pipeline'dan geçmemeli. Bu yüzden 3 kademe var:

**Hafif** — Tek dosya değişikliği, güvenlik yüzeyi yok. Sadece backend-developer yazar, Team Lead onaylar. Bitti.

**Normal** — Standart feature'lar. Backend-developer yazar, Team Lead review eder, quality-gate kontrol eder. Varsayılan yol bu.

**Tam** — Auth, ödeme, migration, public API. Backend-developer yazar, security-reviewer inceler, Team Lead review eder, quality-gate tam kontrol çalıştırır. Eksik varsa döngü baştan başlar.

Kademe seçimi otomatik. Claude görevi analiz edip uygun kademeyi kendisi belirliyor.

### Feedback Döngüsü

Agent'lar birbirleriyle konuşamaz. Tüm iletişim Team Lead (Claude) üzerinden geçer. Security-reviewer bir sorun bulduysa, backend-developer'a "şunu düzelt" diye geri gider. Düzeltilir, tekrar review edilir. Maksimum 3 döngü — çözülmezse bana (insana) eskalasyon yapılır.

Bu, gerçek bir mühendislik takımının çalışma şeklinin aynısı.

---

## Gerçek Bir Örnek

Diyelim ki Claude Code'a şunu söyledim:

> "Kullanıcı profil güncelleme endpoint'i ekle"

Claude (Team Lead olarak) şu adımları izliyor:

1. Görevi analiz eder — Auth içeriyor mu? Evet, kullanıcı kendi profilini güncelliyor. **Harden mode aktif.**
2. Pipeline kademesi: **Tam** (auth yüzeyi var)
3. `backend-developer`'a delege eder — Controller, service, validation yazılır
4. `security-reviewer` inceler — IDOR açığı var mı? Kullanıcı başkasının profilini güncelleyebilir mi? Input validation yeterli mi?
5. Team Lead review eder — İş mantığı doğru mu? Edge case'ler düşünülmüş mü?
6. `quality-gate` çalışır — 11 noktalık kontrol listesi
7. Bana rapor sunar — Ne yapıldı, hangi kontroller geçti, kalan riskler neler

Ben sadece görevi verdim. Pipeline'ı, agent seçimini, güvenlik kontrolünü Claude kendisi yönetti.

---

## Neden "Prompt Engineering" Yetmiyor?

"Ama ben de Claude'a 'güvenliğe dikkat et' diyorum" diyebilirsiniz. Fark şu:

**Prompt ile:** "Güvenliğe dikkat et" diyorsunuz → Claude kodu yazarken aklında tutuyor (belki) → Tek bir bakış açısı

**Governance ile:** Kod yazıldıktan sonra ayrı bir agent güvenlik review yapıyor → Farklı bakış açısı, farklı kontrol listesi → Sorun bulunursa düzeltme döngüsü başlıyor

Birincisi "dikkat et" demek. İkincisi **sistematik kontrol**. İnsan takımlarında da "dikkat et" demek yerine code review süreci var — aynı mantık.

---

## 4 Mühendislik Modu

Her görev aynı hassasiyette ele alınmıyor:

- **explore** — Deneysel çalışma, PoC. Kalite kontrolü gevşek.
- **build** — Standart feature geliştirme. Normal kontrol. Varsayılan mod.
- **harden** — Auth, ödeme, migration, güvenlik. Sıkı kontrol, tam pipeline zorunlu.
- **incident** — Canlı hata, veri kaybı riski. Kritik mod.

Modu belirtmezseniz Claude otomatik seçer. Auth ile ilgili bir şey söylerseniz harden'a geçer. "Production'da hata var" derseniz incident moduna geçer.

---

## Kurulum 5 Dakika

1. Repo'yu klonlayın
2. Projenizden symlink oluşturun
3. Çalışmaya başlayın

```bash
git clone https://github.com/UfukCetinkaya57/claude-code-governance.git

# Linux/Mac
ln -s /path/to/claude-code-governance /path/to/your-project/backend-governance

# Windows
mklink /D "C:\proje\backend-governance" "C:\claude-code-governance"
```

Claude Code projenizi açtığında governance dosyalarını otomatik algılar ve Team Lead olarak çalışmaya başlar.

---

## Kim İçin?

- **Solo geliştiriciler** — Arkanda review yapacak biri yoksa, Claude o rolü üstleniyor
- **Junior geliştiriciler** — Claude seni hatalardan koruyor, her adımda neden yapıldığını açıklıyor
- **Küçük takımlar** — Dedicated bir security reviewer veya architect tutamıyorsanız, Claude bu rolleri simüle ediyor
- **Claude Code kullanan herkes** — Daha yapılandırılmış, daha güvenli, daha kaliteli çıktı istiyorsanız

---

## Açık Kaynak

Framework tamamen açık kaynak (MIT lisans). Fork edin, uyarlayın, katkıda bulunun.

Şu an .NET, Node.js ve Laravel için stack profilleri mevcut. Kendi stack'inizi ekleyebilirsiniz.

GitHub: https://github.com/UfukCetinkaya57/claude-code-governance

---

*Claude Code'u sadece "kod yazan bir araç" olarak kullanmak, bir Formula 1 aracını şehir içi trafikte sürmek gibi. Potansiyeli çok daha fazla — sadece doğru yapılandırma gerekiyor.*
