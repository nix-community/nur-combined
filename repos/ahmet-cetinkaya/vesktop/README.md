# 💬 Vesktop/Vencord Config

This guide helps you set up symbolic links to use a custom [**Vencord**](https://github.com/Vendicated/Vencord) configuration for Vesktop.

## ⚙️ Setup

1. Open a terminal with the necessary permissions for your operating system.

2. Run the appropriate command below to link your custom configuration to Vesktop's default location:

   - **Windows:**
     ```powershell
     New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERNAME\AppData\Roaming\Vesktop" -Target "C:\Users\$env:USERNAME\Configs\vesktop"
     ```
     - The `$env:USERNAME` variable automatically replaces with your Windows username.
     - Replace `C:\Users\$env:USERNAME\Configs\vesktop` with the path to your custom configuration folder.

   - **Linux:**
     ```sh
     ln -s ~/Configs/vesktop ~/.config/vesktop
     ```
     - This uses the general Vesktop config location on Linux.

   These commands create a symbolic link from the default Vesktop config location to your custom configuration folder.
