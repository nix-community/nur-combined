# 🐚 Powershell

This guide helps you set up various tools and customize the appearance of your powershell environment. Below are the tools, configurations, and installation steps to enhance your development experience.

## 🛠 Tools

1. **[Starship](https://github.com/starship/starship)** - A fast and customizable prompt for any shell. - **[Config](https://github.com/ahmet-cetinkaya/dotfiles-public/tree/main/starship)**
   - Alternative: **[Oh My Posh](https://github.com/JanDeDobbeleer/oh-my-posh)** & **[PoshGit](https://github.com/dahlbyk/posh-git)** - **[Config](https://github.com/ahmet-cetinkaya/dotfiles-public/tree/main/oh-my-posh)**

2. **[PSReadLine](https://github.com/PowerShell/PSReadLine)** - Enhances the command line experience in PowerShell.

3. **[GitUI](https://github.com/extrawurst/gitui)** - A terminal-based Git UI for enhanced Git experience.

4. **[PSFzf](https://github.com/kelleyma49/PSFzf)** - Fuzzy Finder for PowerShell to quickly search and navigate your file system.

5. **[Z](https://github.com/badmotorfinger/z)** - Tracks and navigates frequently used directories in your shell.

6. **[gsudo](https://github.com/gerardog/gsudo)** - A sudo-like tool for Windows that allows you to run commands with elevated privileges in PowerShell.

7. **[WinFetch](https://github.com/lptstr/winfetch)** - A simple system information fetcher for Windows. - **[Config](https://github.com/ahmet-cetinkaya/dotfiles-public/tree/main/winfetch)**

8. **[GitOpen](https://github.com/paulirish/git-open)** - Open your current Git project in the browser easily.

## 🎨 Appearance Customization

1. **[Windows Terminal](https://github.com/microsoft/terminal)** - A modern, feature-rich terminal for Windows.
   - **[Config](https://github.com/ahmet-cetinkaya/dotfiles-public/windows-terminal)**

2. **[Nerd Font - CascadiaCode](https://github.com/ryanoasis/nerd-fonts)** - A monospaced font with icons and ligatures for better aesthetics and readability.

## ⚙️ Setup

### 1. **PowerShell Configuration**

To set up **PowerShell** with your custom profile, follow these steps:

1. **Create Symbolic Link for PowerShell Profile:**

   Open a **PowerShell** terminal with Administrator privileges, and run the following command to link your custom profile:

   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\Users\$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Target "C:\Users\$env:USERPROFILE\Configs\powershell\Microsoft.PowerShell_profile.ps1"
   ```

   - This will link your custom PowerShell profile to the designated location.
   - Ensure to replace `$env:USERPROFILE` with your actual user profile path if needed.

2. **Verify the Profile:**

   - Open **PowerShell** and check if your custom profile is applied, such as the prompt, aliases, and themes.
   - You should see your custom **Starship** or **Oh My Posh** prompt.
