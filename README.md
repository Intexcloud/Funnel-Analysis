# 🛒 Ecommerce Funnel Analysis & A/B Testing Simulation

Proyek ini melakukan analisis **end‑to‑end funnel** terhadap data transaksi e‑commerce, mengidentifikasi titik bottleneck, dan menyimulasikan **A/B testing** untuk mendemonstrasikan alur kerja eksperimen bisnis.

**Dataset:** 5.000 pelanggan, 9.000 pesanan, 6 kategori produk, 4 metode pembayaran.  
**Tools:** Python (pandas, matplotlib, seaborn, scipy), SQL, Looker Studio.

---

## 📌 Problem Statement

Manajemen ingin mengetahui:
1. Di tahap mana **drop‑off terbesar** terjadi dalam perjalanan pelanggan?
2. Kategori produk mana yang memiliki **tingkat retur tertinggi** setelah barang dikirim?
3. Metode pembayaran apa yang paling banyak menyebabkan **pembatalan pesanan**?
4. Bagaimana kita bisa mengukur dampak perubahan (misal: desain halaman checkout) secara **statistik** dengan A/B testing?

---

## 📂 Data & Methodology

### Data Sources
- `customers.csv` – data pelanggan
- `orders.csv` – data pesanan (status & payment method)
- `order_items.csv` – detail item dalam setiap pesanan
- `products.csv` + `categories.csv` – informasi produk & kategori
- `returns.csv` – data pengembalian barang

### Process
1. **Data Integration**: Menggabungkan seluruh tabel menggunakan `order_id`, `product_id`, dan `category_id`.
2. **Data Wrangling**: Membersihkan duplikasi, menambahkan flag `is_returned`, dan membuat dataset ringkasan per order.
3. **Funnel Analysis**: Menghitung jumlah order di setiap tahap (Total → Delivered → Completed → Returned).
4. **Root Cause Analysis**:  
   - Cancel rate per payment method  
   - Return rate per product category (hanya pesanan *Delivered*)
5. **Simulated A/B Testing**: Membagi data secara acak menjadi Grup A & B, lalu menguji perbedaan delivery rate menggunakan **Z‑test dua proporsi**.
6. **Visualization**: Membuat chart untuk setiap insight dan menyusun dashboard interaktif (Looker Studio).

---

## 📊 Key Insights & Findings

### 1. Funnel Konversi Order
| Stage                  | Count | Conversion Rate |
|------------------------|-------|-----------------|
| Total Orders           | 9.000 | 100%            |
| Delivered              | 5.634 | 62.6%           |
| Completed (no return)  | 4.458 | 49.5%           |
| Returned               | 1.176 | 13.1%           |

**Insight:**  
- **37.4% pesanan tidak terkirim** (canceled/in transit) – potensi kendala di operasional atau pembayaran.
- **13.1% pesanan dikirim mengalami retur** – memerlukan investigasi lebih lanjut pada kualitas produk/deskripsi.

### 2. Customer Purchase Rate
- **Total Customers:** 5.000  
- **Purchasing Customers:** 4.162  
- **Purchase Rate:** 83.24%  
- **Drop‑off (tidak membeli):** **16.7%**

**Insight:**  
16.7% pelanggan terdaftar tidak pernah bertransaksi. Ini bisa diakibatkan oleh pengalaman browsing yang kurang meyakinkan, harga, atau ketersediaan produk.

### 3. Return Rate per Kategori (Delivered Only)
| Kategori                  | Return Rate |
|---------------------------|-------------|
| Beauty/Cosmetics          | 59.23%      |
| Apparel/Fashion           | 57.99%      |
| Electronics               | 57.29%      |
| Toys                      | 55.95%      |
| Food & Beverages          | 54.50%      |
| Home & Kitchen Furniture  | 54.17%      |

*Catatan: Return rate yang tinggi menunjukkan data ini bersifat sintetis/tidak realistis untuk bisnis nyata. Dalam konteks portofolio, yang terpenting adalah metodologi perhitungan yang benar.*

**Insight:**  
- Seluruh kategori memiliki return rate >50%, sehingga tidak ada perbedaan signifikan antar kategori.  
- Dalam skenario nyata, analis akan menyelidiki penyebab tingginya retur (kualitas produk, ketidaksesuaian deskripsi, atau masalah pengiriman).

### 4. Cancel Rate per Payment Method
| Payment Method     | Cancel Rate |
|--------------------|-------------|
| Cash on Delivery   | 35.2%       |
| Net Banking        | 32.1%       |
| UPI                | 30.5%       |
| Loyalty Points     | 28.9%       |

**Insight:**  
- **Cash on Delivery** memiliki cancel rate tertinggi – logis karena tidak ada komitmen finansial di awal.  
- Rekomendasi: Berikan insentif (diskon/cashback) untuk metode prabayar guna menurunkan cancel rate.

### 5. Simulasi A/B Testing
- Grup A dan B dibentuk secara acak (random assignment).  
- Hasil Z‑test: p‑value > 0.05 → **tidak ada perbedaan signifikan** pada delivery rate.  
- **Kesimpulan:** Ini adalah hasil yang diharapkan karena tidak ada perlakuan khusus. Dalam eksperimen nyata, perusahaan dapat menguji perubahan (misal: desain checkout baru) dengan kerangka kerja yang sama.

---

## 🛠️ Tech Stack & Highlights

- **Python (pandas):** Data integration & wrangling
- **SQL:** Validasi return rate per kategori (CTE + LEFT JOIN)
- **scipy.stats:** Z‑test dua proporsi
- **matplotlib/seaborn:** Visualisasi funnel, cancel rate, return rate
- **Looker Studio:** Dashboard interaktif

*Catatan: Label di dashboard sebelumnya sempat tertukar (“Overall Return Rate 83,24%” seharusnya “Customer Purchase Rate”). Di proyek ini, semua label telah dikoreksi.*

---

## 🚀 Cara Menjalankan

1. Clone repo ini.
2. Pastikan file CSV berada di folder yang sama.
3. Jalankan script Python:
   ```bash
   python funnel_analysis.py
