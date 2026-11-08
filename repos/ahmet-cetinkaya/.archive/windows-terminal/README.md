# 🖥️ Windows Terminal Custom Config Setup

This guide will help you set up symbolic links to use a custom **Windows Terminal** configuration file (`settings.json`).

## ⚙️ Setup

1. **Open PowerShell as Administrator**.

2. **Create Symbolic Link**:
   Run the following command to link your custom **Windows Terminal** `settings.json` file to its default location:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "C:\Users\$env:USERNAME\Configs\windows-terminal\settings.json"
   ```

   - The `$env:USERNAME` variable automatically gets replaced with your Windows username.
   - Replace `C:\Users\$env:USERNAME\Configs\windows-terminal\settings.json` with the path to your custom **Windows Terminal** `settings.json` file.
   - This command creates a symbolic link from the default Windows Terminal config location to your custom configuration file.
