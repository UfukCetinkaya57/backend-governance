# CONTEXT YONETIMI

**Birincil muhatap: Team Lead.** Agent handoff, context dagitimi ve oturum yonetimi Team Lead'in sorumlulugundadir. Agent'lar icin gecerli kurallar (output ozetleme, dosyaya yazma) ilgili basliklar altinda belirtilmistir.

## Ilke
LLM'ler uzun konusmalarda bilgi kaybeder. Bunu bilerek calis.

---

## Lost-in-Middle Kurali

LLM'ler konusmanin **basini ve sonunu** iyi hatirlar, **ortasini** kaybeder.

- Kritik bilgi (karar, kisitlama, gereksinim) prompt'un **basina veya sonuna** yaz
- Uzun context'te onemli talimati ortaya gomme
- Agent handoff'larda en onemli bilgiyi ilk satirda ver

---

## Dort Kova Modeli

Context dolulugu arttiginda bu 4 stratejiyi uygula:

### 1. Write (Dosyaya Yaz)
- Uzun analiz sonuclarini dosyaya yaz, context'te tutma
- Plan, bulgu, ara sonuc → dosya veya memory'ye kaydet
- "Bunu hatirlayacagim" yerine "bunu dosyaya yaziyorum" de

### 2. Select (Filtrele)
- Agent'lara sadece gorevle ilgili bilgiyi gonder
- Tum context'i aktarma — handoff'ta sadece: ne yapildi, ne bekleniyor, nelere dikkat
- Gereksiz tool output'larini ozetleyerek aktar

### 3. Compress (Ozetle)
- Uzun tool sonuclarini ozetle, ham veriyi tasima
- 100 satirlik grep sonucu yerine "X dosyada Y pattern bulundu" de
- Tekrar eden bilgiyi bir kez yaz, referans ver

### 4. Isolate (Dagit)
- Bagimsiz gorevleri ayri subagent'lara ver — her biri temiz context'te calisir
- Paralel agent'lar context paylasMAZ — bu avantajdir, kirlilik yayilmaz
- Buyuk gorevleri bolumle: arastirma agent'i + uygulama agent'i

---

## Uzun Oturum Kurallari

- Context uzadiysa (cok sayida mesaj/tool ciktisi) → `memory/MEMORY.md` ve `proje/` dosyasini **yeniden oku**
- Onceki mesajlardaki kararlara guvenme — dosyadan dogrula
- Karmasik gorevlerde ara checkpoint'ler olustur: "Buraya kadar yapilan..." ozetini yaz
- Subagent sonuclari uzunsa ozet cikart, ham ciktiyi context'e birakma

---

## Agent Handoff Kurali

Bir agent'tan digerine gecerken aktarilacak bilgi **minimal ve yapilandirilmis** olmali:

```
1. Ne yapildi (2-3 cumle ozet)
2. Degisen dosyalar (liste)
3. Onceki agent bulgulari (varsa, ozetlenmis)
4. Bu agent'tan beklenen (net gorev)
5. Dikkat edilecekler (riskler, kisitlamalar)
```

Tum konusma gecmisini aktarma. Agent'in `Beklenen Input` bolumunu kontrol et, eksik bilgi gonderme.
