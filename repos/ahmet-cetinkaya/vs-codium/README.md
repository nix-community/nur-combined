# 🖥️ VSCodium Custom Configs Setup

Set up symbolic links to use custom configuration files in VSCodium.

## 🪟 Windows

1. Open **PowerShell as Administrator**.
2. Run the following commands:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\<USER_NAME>\AppData\Roaming\VSCodium\User\settings.json" -Target "C:\Users\ahmetcetinkaya\Configs\vs-codium\settings.json"
   New-Item -ItemType SymbolicLink -Path "C:\Users\<USER_NAME>\AppData\Roaming\VSCodium\product.json" -Target "C:\Users\ahmetcetinkaya\Configs\vs-codium\product.json"

   # Create symlinks for keybindings.json in all profile directories
   Get-ChildItem "C:\Users\<USER_NAME>\AppData\Roaming\VSCodium\User\profiles\*" -Directory | ForEach-Object {
       New-Item -ItemType SymbolicLink -Force -Path "$($_.FullName)\keybindings.json" -Target "C:\Users\ahmetcetinkaya\Configs\vs-codium\keybindings.json"
   }
   ```

   Replace `<USER_NAME>` with your Windows username.

## 🐧 Linux

1. Open a terminal.
2. Run the following commands:

   ```bash
   ln -sf ~/Configs/vs-codium/product.json ~/.config/VSCodium/product.json
   ln -sf ~/Configs/vs-codium/settings.json ~/.config/Code/User/settings.json

   # Create symlinks for keybindings.json in all profile directories
   find ~/.config/Code/User/profiles/* -maxdepth 0 -type d -exec ln -sf ~/Configs/vs-codium/keybindings.json {}/keybindings.json \;
   ```

## 🔄 Extension Sync Setup

### 1. Install the Extension Sync Extension

- Install the [Extension Sync](https://marketplace.visualstudio.com/items?itemName=e4mi.extension-sync) extension for VSCodium/VSCode.
  - To install from the terminal:
    ```bash
    codium --install-extension e4mi.extension-sync
    # or if you use VSCode
    code --install-extension e4mi.extension-sync
    ```

### 2. Sync Extensions Using the Extension

- Open the command palette (`Ctrl+Shift+P`).
- Run the command: `Extension Sync: Load from User Settings JSON`.
- If needed, specify your settings file path: `~/Configs/vs-codium/settings.json`

> These steps will automatically install and synchronize the extensions defined in your settings file.
