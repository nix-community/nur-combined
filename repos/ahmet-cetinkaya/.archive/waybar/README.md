# 🌟 Waybar Configuration

[Waybar](https://github.com/Alexays/Waybar) is a highly customizable bar for Wayland compositors like Sway and Hyprland. This guide will show you how to set up **Waybar** to use custom configuration files by creating a symbolic link to the **`~/.config/waybar`** folder.

## ⚙️ Setup

1. **Create a Symbolic Link for the Waybar Configuration Folder**:

   Create a symbolic link from your custom configuration files to **`~/.config/waybar`** by running the following command:

   ```bash
   ln -s ~/Configs/waybar ~/.config/waybar
   ```

   Replace `~/Configs/waybar` with the path where your custom **Waybar** configuration files (e.g., `config`, `style.css`) are stored.

2. **Restart Wayland Session**:

   After creating the symbolic link, restart your Wayland session or reload your compositor (e.g., Sway or Hyprland) to apply the new **Waybar** configuration.

   If **Waybar** is not set to auto-start, you can add this line to your Wayland compositor's configuration file (e.g., `~/.config/sway/config` or `~/.config/hyprland/hyprland.conf`):

   ```bash
   exec waybar
   ```