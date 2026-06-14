# 📦 nix-custompkgs

![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat-square&logo=NixOS&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

Koleksi *custom derivations*, *wrappers*, dan Home Manager Modules pribadi yang belum tersedia di repositori resmi `nixpkgs`, atau membutuhkan penyesuaian khusus (*library injection*, *dynamic linking*) agar dapat berjalan optimal di lingkungan sistem operasi Linux.

Repositori ini ditenagai sepenuhnya oleh **Nix Flakes** untuk menjamin integrasi yang deklaratif, terisolasi, dan mudah direproduksi (reproducible).

---

## 📦 Tersedia di Repositori Ini

### 🛠️ Custom Packages
Paket-paket mandiri yang bisa dieksekusi langsung atau diinstal secara global:
| Nama Paket | Deskripsi |
| :--- | :--- |
| `binance` | Utilitas / Klien CLI untuk ekosistem dan trading Binance. |
| `disbox` | Alat bantu untuk menjadikan Discord sebagai media penyimpanan *cloud*. |
| `streambert` | Utilitas *streaming* / pemrosesan media. |
| `teldrive` | *Mount* atau gunakan Telegram API sebagai penyimpanan *cloud* tak terbatas. |
| `uabea` | Unity Assets Bundle Extractor Avalon. |
| `vimmdl` | CLI *downloader* untuk mengunduh ROM konsol retro / berkas dari Vimm's Lair. |

### 🧩 Home Manager Modules
Modul deklaratif untuk mengotomatiskan setup lingkungan kerja:
* **`freqtrade-setup`**: Modul cerdas untuk menginisialisasi, memperbarui, dan menjalankan *bot trading* Freqtrade secara global dengan isolasi `venv` dan injeksi *library* C (`ta-lib`) secara dinamis.

---

## 🚀 Quick Start (Coba Tanpa Install)

Kamu tidak perlu menginstal paket-paket ini secara permanen. Jika sistemmu sudah mendukung Nix Flakes, kamu bisa langsung mengeksekusi aplikasinya dari terminal di mana saja:

```bash
# Contoh menjalankan Unity Assets Bundle Extractor Avalon
nix run github:XiaoXioe/nix-custompkgs#uabea

```

---

## 💻 Instalasi via NixOS / Home Manager

Untuk menginstal paket secara permanen atau menggunakan modul Home Manager, tambahkan repositori ini ke dalam `flake.nix` sistem utama kamu.

### 1. Tambahkan ke Inputs Flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Tambahkan custompkgs
    custompkgs.url = "github:XiaoXioe/nix-custompkgs";
  };
}

```

### 2. Instalasi Custom Packages

Panggil paket yang diinginkan pada konfigurasi sistem atau user (`home.nix` / `configuration.nix`):

```nix
{ pkgs, inputs, system, ... }:
{
  home.packages = [
    inputs.custompkgs.packages.${system}.uabea
    inputs.custompkgs.packages.${system}.teldrive
  ];
}

```

---

## 🤖 Dokumentasi Modul: Freqtrade Setup

Modul `freqtrade-setup` memungkinkan kamu mendeploy lingkungan kerja Freqtrade yang sepenuhnya otomatis, lengkap dengan Git cloning, manajemen Virtual Environment, dan dukungan paket `pip` tambahan.

### Cara Penggunaan

Tambahkan *import* dan opsi berikut ke dalam `home.nix` kamu:

```nix
{ config, inputs, ... }:
{
  imports = [
    inputs.custompkgs.homeModules.freqtrade-setup
  ];

  programs.freqtrade-setup = {
    enable = true;
    
    # Direktori tempat core mesin Freqtrade & .venv akan diinstal (terpisah dari data pengguna)
    configDir = "${config.home.homeDirectory}/freqtrade-core"; 
    
    # (Opsional) Branch repositori Freqtrade yang digunakan
    branch = "stable"; 
    
    # (Opsional) Paket PIP ekstra untuk keperluan Machine Learning / Hyperopt
    extraPip = [ 
      "scipy" 
      "optuna" 
      "plotly"
    ];

    # (Opsional) Manajemen otomatisasi background service via Systemd
    service = {
      enable = true;
      
      bots = {
        # Kamu bisa mendefinisikan banyak bot sekaligus (bot1, bot2, dst)
        bot-utama = {
          enable = true;
          
          # Folder tempat config.json, database SQLite, dan folder user_data/strategies berada
          strategiesDir = "/path/ke/folder/strategi/kamu";
          
          # Nama class strategi yang akan dijalankan
          strategyRun = "NamaStrategiKamu";
          
          # (Opsional) Nama file konfigurasi, default: config.json
          configFile = "config.json";
          
          # (Opsional) Argumen CLI tambahan saat bot dieksekusi
          extraOpts = [ "--dry-run" ]; 
        };
      };
    };
  };
}
```

### CLI Commands yang Tersedia

Setelah melakukan `home-manager switch`, kamu akan mendapatkan akses ke tiga perintah global ini:

* `freqtrade-setup` — Menjalankan inisialisasi awal. Secara otomatis melakukan *clone*, membuat `.venv`, dan menyinkronkan *branch* jika ada perubahan di `home.nix`.
* `freqtrade-update` — Membersihkan *cache*, menghapus instalasi lama, dan membangun ulang lingkungan Freqtrade dari nol.
* `freqtrade-venv` — Shortcut untuk langsung masuk (activate) ke Virtual Environment Freqtrade dengan library C (`ta-lib` dll) yang sudah ter-inject secara dinamis ke shell saat ini.
* `freqtrade` — *Wrapper* pintar. Memungkinkan kamu mengeksekusi biner Freqtrade secara langsung dari *folder* mana saja tanpa perlu melakukan aktivasi `.venv` manual.


---

## 📜 Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Silakan gunakan, modifikasi, dan distribusikan sesuai kebutuhan.
