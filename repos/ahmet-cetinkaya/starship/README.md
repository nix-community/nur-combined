# 🐚 Starship Custom Config

Starship is a minimal, fast, and customizable shell prompt. This guide will show you how to configure [**Starship**](https://github.com/starship/starship) to use a custom configuration file by setting the `STARSHIP_CONFIG` environment variable. Instructions are provided for both **Windows** and **Linux** systems.

![zsh on Kitty terminal](../kitty/Screenshot_20250627_212837.png)

## ⚙️ Setup

### 🪟 Windows

1. **Set the `STARSHIP_CONFIG` Environment Variable**:

   In PowerShell, set the `STARSHIP_CONFIG` environment variable to point to your custom `starship.toml` file. Add this line to your PowerShell profile (`$PROFILE`):

   ```powershell
   $env:STARSHIP_CONFIG="C:\Users\<USER_NAME>\Configs\starship\starship.toml"
   ```

   Replace `<USER_NAME>` with your Windows username and ensure the path points to the correct location of your custom `starship.toml`.

2. **Initialize Starship in PowerShell**:

   Add the following line to your PowerShell profile to initialize Starship:

   ```powershell
   eval "$(starship init powershell)"
   ```

3. **Restart PowerShell**:

   Restart your terminal to apply the changes. You should now see your custom Starship prompt with the settings from your `starship.toml` file.

---

### 🐧 Linux

1. **Set the `STARSHIP_CONFIG` Environment Variable**:

   Open your shell configuration file (e.g., `~/.zshrc` for Zsh or `~/.bashrc` for Bash) and add the following line to set the `STARSHIP_CONFIG` environment variable:

   ```bash
   export STARSHIP_CONFIG=$HOME/Configs/starship/starship.toml
   ```

   Replace `$HOME/Configs/starship/starship.toml` with the correct path to your custom `starship.toml` file.

2. **Initialize Starship in Zsh (or Bash)**:

   For **Zsh**, add the following line to your `~/.zshrc` file:

   ```bash
   eval "$(starship init zsh)"
   ```

   For **Bash**, add the following to your `~/.bashrc` file:

   ```bash
   eval "$(starship init bash)"
   ```

3. **Restart Your Shell**:

   After adding the necessary configuration, restart your terminal or run:

   ```bash
   source ~/.zshrc   # for Zsh
   source ~/.bashrc  # for Bash
   ```

   Your custom **Starship** prompt should now be active with the settings from your `starship.toml` file.
