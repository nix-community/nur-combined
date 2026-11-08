# 🖼️ Winfetch Custom Config Setup

This guide helps you set up symbolic links to use custom [**winfetch**](https://github.com/lptstr/winfetch) configuration files.

## ⚙️ Setup

1. **Open PowerShell as Administrator**.

2. **Create Symbolic Link**:
   Run the following command to link your custom **winfetch** configuration files to their default location:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\.config\winfetch" -Target "C:\Users\$env:USERNAME\Configs\winfetch"
   ```

   - The `$env:USERNAME` variable automatically gets replaced with your Windows username.
   - Replace `C:\Users\$env:USERNAME\Configs\winfetch` with the path to your custom **winfetch** configuration files.
   - This command creates a symbolic link in the default **winfetch** configuration folder.