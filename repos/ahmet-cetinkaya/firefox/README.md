# 🔥 Firefox Custom Config

This guide helps you set up symbolic links to use a custom **Firefox** `user.js` configuration file on both **Windows** and **Linux**.

## ⚙️ Setup

### 🪟 Windows Setup

1. **Open PowerShell as Administrator**.

2. **Create Symbolic Link**:
   Run the following command to link your custom **Firefox** `user.js` file to its default location:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\AppData\Roaming\Mozilla\Firefox\Profiles\h1u1rfoq.default-release\user.js" -Target "C:\Users\$env:USERNAME\Configs\firefox\user.js"
   ```

   - Replace `$env:USERNAME` with your actual Windows username.
   - Replace `C:\Users\$env:USERNAME\Configs\firefox\user.js` with the path to your custom **Firefox** `user.js` file.

### 🐧 Linux Setup

1. **Open a terminal**.

2. **Create Symbolic Link**:
   Run the following command to link your custom **Firefox** `user.js` file to its default location:

   ```bash
   ln -s ~/Configs/firefox/user.js ~/.mozilla/firefox/h1u1rfoq.default-release/user.js
   ```

   - Replace `~/Configs/firefox/user.js` with the path to your custom **Firefox** `user.js` file.