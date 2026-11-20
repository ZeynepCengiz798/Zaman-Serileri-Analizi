# ✈️ Havayolu Yolcu Taşımacılığı Fiyat Endeksinin Zaman Serisi Analizi

Türkiye'de havayolu ile yolcu taşımacılığı fiyat endeksinin (2017–2025) aylık verisi üzerinde **ayrıştırma, regresyon, üstel düzleştirme (Winters) ve Box–Jenkins (ARIMA)** yöntemlerinin uygulandığı, **R** ile hazırlanmış zaman serisi analizi projesidir.

---

## 📌 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Veri Seti](#-veri-seti)
- [Kullanılan Yöntemler](#-kullanılan-yöntemler)
- [Sonuçlar](#-sonuçlar)
- [Öngörüler](#-öngörüler)
- [Proje Yapısı](#-proje-yapısı)
- [Kurulum ve Çalıştırma](#-kurulum-ve-çalıştırma)
- [Kullanılan Teknolojiler](#-kullanılan-teknolojiler)
- [İletişim](#-iletişim)

---

## 🎯 Proje Hakkında

Çalışmanın amacı, havayolu yolcu taşımacılığı fiyat endeksinin **trend**, **mevsimsellik** ve **rassal** bileşenlerini ortaya koymak, farklı yöntemleri tanısal testlerle karşılaştırmak ve en uygun modelle **gelecek 5 ay için öngörü** üretmektir.

Projede şu sorulara yanıt aranmıştır:

- Seride belirgin bir **trend** ve **mevsimsellik** var mı?
- Seri durağan mı, değilse nasıl durağanlaştırılır?
- Hangi yöntemin hata serisi **ak gürültü** (otokorelasyonsuz) çıkıyor?
- Geçerli bulunan modeller gelecek dönemler için ne öngörüyor?

---

## 📊 Veri Seti

| Özellik | Açıklama |
| --- | --- |
| Seri | TÜİK – Hizmet Üretici Fiyat Endeksi (2017=100) – Hava Yolu Taşımacılığı |
| Seri kodu | `TP HUFE GK18203` |
| Kaynak | T.C. Merkez Bankası Elektronik Veri Dağıtım Sistemi (EVDS) |
| Dönem | Ocak 2017 – Eylül 2025 |
| Frekans | Aylık (`frequency = 12`) |
| Gözlem sayısı | 105 |

Seri 2017'de yaklaşık 90 seviyesinden başlayıp 2025 Ağustos'ta 2118,51 ile zirve yapmıştır. Grafikte belirgin bir **artan trend** ve düzenli aralıklarla tekrar eden **mevsimsel dalgalanmalar** gözlenmektedir.

---

## 🛠️ Kullanılan Yöntemler

1. **Ön inceleme ve durağanlaştırma**
   - Zaman serisi grafiği, ACF / PACF analizi
   - ACF'nin yavaş sönümlenmesi güçlü trendi gösterdiği için **birinci fark** (d=1), periyot 12 olarak belirlenip **mevsimsel fark** (D=1) alınmıştır.
2. **Ayrıştırma yöntemleri**
   - Toplamsal ve çarpımsal ayrıştırma (merkezsel hareketli ortalama, mevsimsel endeks, `tslm` ile trend)
3. **Regresyon modelleri**
   - Trigonometrik terimlerle (harmonikler) toplamsal ve çarpımsal regresyon, Durbin–Watson testi
4. **Üstel düzleştirme**
   - Toplamsal Winters: `ets(model = "AAA")`
   - Çarpımsal Winters: `ets(model = "MAM")`
5. **Box–Jenkins (ARIMA)**
   - 15 farklı SARIMA kombinasyonu denenmiş, katsayı anlamlılığı (`coeftest`), BIC ve RMSE ile karşılaştırılmıştır.
6. **Model geçerlilik kontrolü**
   - Hata serisinin ACF/PACF grafikleri ve **Box–Ljung** testi ile ak gürültü varsayımı sınanmıştır.
7. **Öngörü**
   - Geçerli bulunan modellerle 5 aylık öngörü (Ekim 2025 – Şubat 2026)

---

## 📈 Sonuçlar

| Yöntem | Hata serisi ak gürültü mü? | Sonuç |
| --- | --- | --- |
| Toplamsal ayrıştırma | Hayır (Box–Ljung p < 0,05) | ❌ Uygun değil |
| Çarpımsal ayrıştırma | Hayır (Box–Ljung p < 0,05) | ❌ Uygun değil |
| Toplamsal regresyon | sin1 / cos1 katsayıları anlamsız | ❌ Kurulamadı |
| Çarpımsal regresyon | Hayır (DW = 0,0725, Box–Ljung p < 0,05) | ❌ Uygun değil |
| Toplamsal Winters (A,A,A) | Hayır (Box–Ljung p = 0,0018) | ❌ Uygun değil |
| **Çarpımsal Winters (M,Ad,M)** | **Evet** (Box–Ljung lag=24, p = 0,1757) | ✅ **Uygun** |
| **ARIMA(1,1,0)(0,1,0)[12]** | **Evet** (Box–Ljung lag=42, p = 0,6041) | ✅ **Uygun** |

### Geçerli bulunan modellerin performansı

| Model | RMSE | MAE | MAPE (%) | AIC | BIC |
| --- | --- | --- | --- | --- | --- |
| Çarpımsal Winters ETS(M,Ad,M) | 32,95 | 19,61 | 3,58 | 1140,12 | 1187,89 |
| ARIMA(1,1,0)(0,1,0)[12] | 37,13 | 23,20 | 3,82 | 942,36 | 947,41 |
| ARIMA(0,1,1)(0,1,0)[12] | 37,15 | 23,15 | 3,83 | 942,45 | 947,49 |

> ℹ️ ARIMA modelleri arasından, en küçük BIC ve RMSE değerleri nedeniyle **ARIMA(1,1,0)(0,1,0)[12]** seçilmiştir (AR(1) katsayısı = 0,2295, p = 0,024). Diğer SARIMA kombinasyonlarında mevsimsel AR/MA katsayıları anlamsız çıkmıştır.

### Temel bulgular

- Seri **güçlü trend ve mevsimsellik** içermektedir; bu yüzden basit ayrıştırma ve regresyon modelleri yetersiz kalmıştır.
- **Üstel düzleştirme (çarpımsal Winters)** ve **Box–Jenkins (ARIMA)** yaklaşımları serinin yapısını başarıyla yakalamıştır.
- Havayolu taşımacılığı fiyatları zaman içinde hem artan bir eğilim hem de güçlü mevsimsel dalgalanmalar sergilemektedir.

---

## 🔮 Öngörüler

| Dönem | Çarpımsal Winters | ARIMA(1,1,0)(0,1,0)[12] |
| --- | --- | --- |
| 2025-10 | 1825,45 | 1829,18 |
| 2025-11 | 1734,23 | 1761,60 |
| 2025-12 | 1780,70 | 1761,91 |
| 2026-01 | 1787,58 | 1751,51 |
| 2026-02 | 1649,96 | 1651,80 |

---

## 📁 Proje Yapısı

```
Zaman-Serileri-Analizi/
│
├── ZAMAN SERİLERİ/
│   ├── ZAMAN SERİLERİ.R        # Tüm analizin R kodu
│   └── ZAMAN SERİSİ RAPOR.pdf  # Adım adım hazırlanan detaylı rapor
│
├── .gitattributes
└── README.md
```

- [`ZAMAN SERİLERİ.R`](ZAMAN%20SER%C4%B0LER%C4%B0/ZAMAN%20SER%C4%B0LER%C4%B0.R): ayrıştırma, regresyon, Winters ve ARIMA adımlarının tamamını içeren kod
- [`ZAMAN SERİSİ RAPOR.pdf`](ZAMAN%20SER%C4%B0LER%C4%B0/ZAMAN%20SER%C4%B0S%C4%B0%20RAPOR.pdf): grafikler, hipotez testleri ve yorumlarla birlikte tam rapor

---

## ⚙️ Kurulum ve Çalıştırma

1. Repoyu indir:

```bash
git clone https://github.com/ZeynepCengiz798/Zaman-Serileri-Analizi.git
```

2. R veya RStudio'da gerekli paketleri yükle:

```r
install.packages(c("readxl", "forecast", "fpp", "fpp2", "lmtest", "haven"))
```

3. Veriyi [EVDS](https://evds2.tcmb.gov.tr/) üzerinden `TP HUFE GK18203` serisi için indirip bir Excel dosyası olarak kaydet.
4. `ZAMAN SERİLERİ.R` dosyasındaki `read_excel(...)` satırında dosya yolunu kendi bilgisayarındaki yola göre güncelle.
5. Kodu yukarıdan aşağıya sırayla çalıştır.

---

## 💻 Kullanılan Teknolojiler

- **R**
- `forecast` (ARIMA, ETS, ACF/PACF), `lmtest` (Durbin–Watson, `coeftest`), `readxl`, `fpp`

---

## 📬 İletişim

**Zeynep Cengiz**
GitHub: [@ZeynepCengiz798](https://github.com/ZeynepCengiz798)
