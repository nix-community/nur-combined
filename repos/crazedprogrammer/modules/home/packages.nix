{ config, lib, pkgs, ... }:

{
  # Allow only these unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.elem (if (builtins.hasAttr "name" pkg) then (builtins.parseDrvName pkg.name).name else pkg.pname)
    [ "steam" "steam-unwrapped" "steam-runtime" "factorio-alpha" "virtualbox"
      "pycharm-professional" "clion" "corefonts" "font-bh-lucidatypewriter"
      "displaylink" ];

  # Fix glava not finding config files.
  environment.etc."xdg/glava".source = "${pkgs.glava}/etc/xdg/glava";

  # Disable telemetry on the .NET CLI.
  environment.variables.DOTNET_CLI_TELEMETRY_OPTOUT = "1";

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget curl jq bc loc p7zip fdupes binutils-unwrapped ls_extended file parallel lz4 ccrypt tree
    (pass.withExtensions (exts: [ exts.pass-otp ])) gnupg pinentry-gtk2

    # Version control
    git subversion

    # Utilities
    qemu stress sysbench
    clang-tools rustfmt rust-analyzer clippy
    pandoc plantuml doxygen graphviz flamegraph
    (texlive.combine {
      inherit (texlive) scheme-small enumitem sectsty;
    })

    # X utilities
    xclip maim slop lxrandr xdotool hhpc xorg.xhost glxinfo redshift
    # Wayland utilities
    grim slurp wf-recorder wl-clipboard

    # Nix utilities
    nix-du

    # Build systems
    gnumake cmake #gradle

    # Libraries
    SDL2 SDL2_image libv4l

    # Languages
    gcc stdenv.cc.cc.lib
    lua5_3 luajit elixir nim
    cargo nodejs #jre
    dotnet-sdk mono
    (urn.override { useLuaJit = true; })

    # Games
    #polymc chip8 riko4
    gnome-mines ccemux the-powder-toy

    # Terminals
    kitty-wrapped alacritty-wrapped

    # Editors
    neovim vscodium

    # Browsers
    firefox
    # Mail client
    thunderbird

    # GTK+ and icon theme (settings)
    arc-theme paper-icon-theme nordic shades-of-gray-theme
    glib gsettings-desktop-schemas

    # Office suite
    gnome-calculator libreoffice-fresh

    # Visual editors
    gimp audacity xfce.mousepad
    #tiled pencil sweethome3d.application
    #fritzing arduino

    # CLI A/V editors
    ffmpeg imagemagick

    # Multimedia
    (xfce.thunar.override { thunarPlugins = [ xfce.thunar-archive-plugin ]; })
    (mpv.override { scripts = [ mpvScripts.mpris ]; })
    viewnior zathura guvcview file-roller #cli-visualizer-wrapped cava-wrapped glava

    # Networking
    openssh bitpocket networkmanagerapplet nmap socat openvpn update-resolv-conf #tigervnc youtube-dl

    # WM utilities
    (polybar.override { pulseSupport = true; }) rofi-wrapped feh dunst-wrapped libnotify xtrlock-pam compton-latest i3lock i3blocks-wrapped

    # Scripts
    dotfiles-bin dotfiles-background

    # System utilities
    pavucontrol playerctl blueberry polkit_gnome exfat ntfs3g rdfind iotop bmon linuxPackages.perf picocom gotop htop sysstat ncdu usbutils
    # Virtualization
    #docker-compose libguestfs-with-appliance virt-manager
    # Vagrant libvirtd support
    #bridge-utils ebtables libxslt libxml2 libvirt zlib
  ] ++ (if builtins.pathExists /home/casper/.factorio.nix
    then lib.singleton (factorio.override (import /home/casper/.factorio.nix))
    else [ ]);
}
