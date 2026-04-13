# 📦 nix-custompkgs

Koleksi *custom derivations* dan paket Nix pribadi yang belum tersedia di `nixpkgs` resmi, atau membutuhkan *tweaks* khusus (seperti *wrapper* atau penyesuaian *library*) agar bisa berjalan mulus di Linux. 

Repositori ini sepenuhnya ditenagai oleh **Nix Flakes** untuk menjamin integrasi yang deklaratif dan mudah direproduksi.

## 🚀 Quick Start (Coba Tanpa Install)

Kamu tidak perlu menginstal paket-paket ini secara permanen. Jika sistemmu sudah mendukung Nix Flakes, kamu bisa langsung mengeksekusi aplikasinya dari terminal (contoh di bawah menggunakan paket `uabea`):

```bash
nix run github:XiaoXioe/nix-custompkgs#uabea
