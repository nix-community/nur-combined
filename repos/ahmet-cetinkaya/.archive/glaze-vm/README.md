# 🖥️ GlazeWM Custom Config

This guide helps you set up symbolic links to use a custom [**Glaze Window Manager**](https://github.com/glzr-io/glazewm) configuration.

## ⚙️ Setup

1. **Open PowerShell as Administrator**.

2. **Create Symbolic Link**:
   Run the following command to link your custom **Glaze WM** configuration to its default location:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\.glaze-wm" -Target "C:\Configs\glaze-vm"
   ```

   - Replace `$env:USERNAME` with your actual Windows username.
   - Replace `C:\Configs\glaze-vm` with the path to your custom **Glaze WM** configuration folder.
