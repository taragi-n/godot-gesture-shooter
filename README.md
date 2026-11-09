# Godot Gesture Shooter

> **"Your hands are your weapons. Move, aim, and survive."**

> Sebuah *2D arcade side-scrolling shooter* yang dikembangkan menggunakan **Godot Engine 4**, dengan sistem kendali berbasis *real-time hand gesture recognition* menggunakan Python.

---

## About The Game

**Godot Gesture Shooter** adalah game arcade shooter 2D yang mengintegrasikan teknologi *hand tracking* sebagai alternatif kontrol permainan. Berbeda dengan game shooter konvensional yang mengandalkan keyboard dan mouse, pemain dapat mengendalikan pergerakan pesawat serta melakukan penembakan hanya melalui gerakan tangan yang ditangkap oleh kamera.

Sistem pengenalan gestur dibangun menggunakan **Python, OpenCV, dan MediaPipe Hands**, kemudian dihubungkan dengan Godot Engine 4 melalui komunikasi jaringan lokal menggunakan protokol **UDP**. Pemain dapat menggerakkan pesawat dengan mengubah posisi tangan, serta menembak dengan mengepalkan tangan.

Hadapi gelombang musuh, kumpulkan berbagai *power-up*, raih skor tertinggi, dan bertahan hidup selama mungkin!

---

## Key Features

- **Hand Gesture Recognition:** Kendali permainan menggunakan deteksi 21 titik landmark tangan melalui MediaPipe Hands.
- **Real-Time UDP Communication:** Integrasi Python dan Godot Engine 4 menggunakan protokol UDP pada port 4242.
- **Gesture-Based Controls:** Gerakkan pesawat menggunakan posisi tangan dan aktifkan tembakan dengan gestur mengepal.
- **Power-Up System:** Lima jenis item dengan efek berbeda, yaitu Health, Shield, Speed, Triple Shot, dan Super Missile.
- **Weight-Based RNG:** Sistem distribusi item berdasarkan probabilitas untuk menjaga keseimbangan permainan.
- **Arcade Scoring System:** Sistem skor tiga digit, indikator HP dinamis, serta tampilan timer untuk item aktif.
- **Game Loop & Replay:** Dilengkapi Standby Screen, Active Gameplay, dan Game Over Screen dengan transisi animasi.

---

## Tech Stack & Tools

- **Engine:** Godot Engine 4
- **Game Language:** GDScript
- **Programming Language:** Python
- **Computer Vision:** OpenCV
- **Hand Tracking:** MediaPipe Hands
- **Communication Protocol:** UDP Socket (Localhost / Port 4242)
- **Development Environment:** Visual Studio Code

---

## How to Run Locally

### Prerequisites

- Godot Engine 4
- Python 3
- Webcam / Camera
- Python dependencies (OpenCV dan MediaPipe)

### Steps

1. Clone repositori ini:

   ```bash
   git clone https://github.com/taragi-n/godot-gesture-shooter.git
   ```

2. Masuk ke direktori proyek:

   ```bash
   cd godot-gesture-shooter
   ```

3. Buka terminal dan instal dependency Python:

   ```bash
   pip install opencv-python mediapipe
   ```

4. Buka **Godot Engine 4**.

5. Klik tombol **Import**, lalu pilih file `project.godot` dari folder repositori.

6. Tekan **F5** (atau klik ikon **Play** di kanan atas) untuk menjalankan game.

7. Pastikan kamera terhubung dan dapat digunakan. Sistem hand tracking akan dijalankan secara otomatis oleh game.

### Controls

- **Space:** Memulai permainan atau melakukan replay.
- **Move Hand Up / Down:** Menggerakkan pesawat ke atas dan ke bawah.
- **Closed Fist:** Mengaktifkan tembakan.
- **Open Palm:** Menghentikan tembakan.

---

## Author & Credits

- **Developer:** Gyntara Dwi Novelan
- **Institution:** Universitas Negeri Semarang
- **Project:** Sistem Multimedia

---
*Created by Gyntara Dwi Novelan.*