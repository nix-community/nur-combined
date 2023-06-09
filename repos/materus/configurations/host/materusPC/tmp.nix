{ config, pkgs, lib, inputs, materusFlake, materusPkgs, ... }:
let

  grml-config = pkgs.fetchFromGitHub {
    owner = "grml";
    repo = "grml-etc-core";
    rev = "a2cda85d3d56fd5f5a7b954a444fd151318c4680";
    sha256 = "0ap8lmqi45yjyjazdm1v64fz1rfqhkhfpdp2z17ag6hs5wi6i67y";
  };
in
{
  virtualisation.lxc.enable = true;
  virtualisation.lxc.lxcfs.enable = true;
  virtualisation.lxd.enable = true;
  #virtualisation.lxd.recommendedSysctlSettings = true;

  programs.corectrl.enable = true;
  programs.corectrl.gpuOverclock.enable = true;
  programs.corectrl.gpuOverclock.ppfeaturemask = "0xffffffff";
  programs.gamemode.enable = true;



  services.xserver.displayManager.startx.enable = true;
  services.teamviewer.enable = true;
  
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  services.flatpak.enable = true;
  services.gvfs.enable = true;



  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {
    font = "lat2-16";
    #     keyMap = "pl";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  services.xserver.layout = "pl";

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gcr_4 ];
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.enso.enable = true;
  services.xserver.displayManager.lightdm.greeters.enso.blur = true;

  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.phononBackend = "gstreamer";
  services.xserver.desktopManager.plasma5.useQtScaling = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;

  environment.plasma5.excludePackages = with pkgs; [ libsForQt5.kwallet libsForQt5.kwalletmanager libsForQt5.kwallet-pam ];

  services.xserver.config = pkgs.lib.mkAfter ''
    Section "OutputClass"
      Identifier "amd-options"
      Option "TearFree" "True"
      Option "SWCursor" "True"
      Option "VariableRefresh" "true"
      Option "AsyncFlipSecondaries" "true"
      MatchDriver "amdgpu"
    EndSection

  '';

  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.displayManager.autoLogin.user = "materus";


  services.printing.enable = true;


  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    systemWide = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };
  hardware.pulseaudio.enable = false;

  services.xserver.libinput.enable = true;

  virtualisation.waydroid.enable = true;
  virtualisation.podman = {
    enable = true;
    #enableNvidia = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };


  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.ovmf.enable = true;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.runAsRoot = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.libvirtd.qemu.package = pkgs.qemu_full;
  systemd.services.libvirtd = {
    path =
      let
        env = pkgs.buildEnv {
          name = "qemu-hook-env";
          paths = with pkgs; [
            bash
            libvirt
            kmod
            systemd
            ripgrep
            sd
            coreutils
            sudo
            su
            killall
            procps
            util-linux
            bindfs
          ];
        };
      in
      [ env ];
  };

  users.users.materus = {
    isNormalUser = true;
    extraGroups = [ "pipewire" "wheel" "networkmanager" "input" "kvm" "libvirt-qemu" "libvirt" "libvirtd" "podman" "lxd" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.bashInteractive;
    description = "Mateusz Słodkowicz";
    #   packages = with pkgs; [
    #     firefox
    #     thunderbird
    #   ];
  };
  environment.variables = {
    KWIN_DRM_NO_AMS = "1";
    DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl,rt,sam";
  };
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    #SSH_ASKPASS_REQUIRE = "prefer";

    MOZ_USE_XINPUT2 = "1";
    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };
  environment.shellInit = ''
    if ! [ -z "$DISPLAY" ]; then xhost +si:localuser:root &> /dev/null; fi;
    if ! [ -z "$DISPLAY" ]; then xhost +si:localuser:$USER &> /dev/null; fi;
  '';

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-configtool pkgs.fcitx5-lua pkgs.fcitx5-mozc pkgs.libsForQt5.fcitx5-qt ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  services.samba-wsdd.enable = true;

  services.samba.enable = true;


  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    enableBrowserSocket = true;
    pinentryFlavor = "gtk2";
  };
  programs.ssh.startAgent = true;
  services.openssh.enable = true;

  environment.enableAllTerminfo = true;
  environment.pathsToLink = [ "/share/zsh" "/share/bash-completion" "/share/fish" ];
  environment.shells = with pkgs; [ zsh bashInteractive fish ];
  programs = {
    fish.enable = true;
    zsh = {
      enable = true;
      interactiveShellInit = ''
        if [[ ''${__MATERUS_HM_ZSH:-0} == 0 ]]; then
          source ${grml-config}/etc/zsh/zshrc
        fi
      '';
      promptInit = ''

      '';
    };
    java.enable = true;
    command-not-found.enable = false;
    dconf.enable = true;
  };





  /*containers.test = {
    config = { config, pkgs, ... }: { environment.systemPackages = with pkgs; [ wayfire ]; };
    autoStart = false;
    };*/

  environment.systemPackages = with pkgs; [
    firefox
    gamescope
    #(pkgs.lutris.override { extraLibraries = pkgs: with pkgs;  [ pkgs.samba pkgs.jansson pkgs.tdb pkgs.libunwind pkgs.libusb1 pkgs.gnutls pkgs.gtk3 pkgs.pango ]; })
    materusPkgs.amdgpu-pro-libs.prefixes
    (pkgs.bottles.override { extraPkgs = pkgs: with pkgs; [ pkgs.libsForQt5.breeze-qt5 pkgs.libsForQt5.breeze-gtk pkgs.nss_latest ]; extraLibraries = pkgs: with pkgs; [ pkgs.samba pkgs.jansson pkgs.tdb pkgs.libunwind pkgs.libusb1 pkgs.gnutls pkgs.gtk3 pkgs.pango ]; })
    glibc
    glib
    gtk3
    gtk4
    gsettings-desktop-schemas


    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    patchelf
    killall
    util-linux
    xorg.xhost
    nix-top

    gitFull
    curl
    wget

    jdk

    nss_latest

    aspell
    aspellDicts.pl
    aspellDicts.en
    aspellDicts.en-computers

    distrobox

    p7zip
    unrar
    bzip2
    rar
    unzip
    zstd
    xz
    zip
    gzip

    virtiofsd
    config.virtualisation.libvirtd.qemu.package
    looking-glass-client

    tree
    mc
    lf
    htop
    nmon
    iftop
    iptraf-ng
    mprocs
    tldr
    bat


    # pgcli
    # litecli

    #zenmonitor

    nix-du

    ark
    kate
    krusader

    wineWowPackages.stagingFull
    winetricks
    protontricks
    openal
    gnupg
    pinentry
    pinentry-gnome
    pinentry-curses
    ncurses
    monkeysphere
    gparted

    inkscape
    gimp



    virt-manager
    libguestfs

    bubblewrap
    bindfs

    pulseaudio

    binutils
    config.materus.profile.packages.firefox
    /*
      gnome3.adwaita-icon-theme
      gnome3.gnome-tweaks
      gnome3.gnome-color-manager
      gnome3.gnome-shell-extensions

      gnomeExtensions.appindicator
      gnomeExtensions.desktop-clock
      gnomeExtensions.gtk4-desktop-icons-ng-ding
      gnomeExtensions.compiz-windows-effect
      gnomeExtensions.burn-my-windows
      gnomeExtensions.user-themes
      gnomeExtensions.gsconnect
      gnomeExtensions.dash-to-panel
      gnomeExtensions.dash-to-dock
    */
  ];


  /*
    system.activationScripts.libvirt-hooks.text =
    ''
    ln -Tfs /etc/libvirt/hooks /var/lib/libvirt/hooks
    '';



    environment.etc = {
    "libvirt/hooks/qemu" = {
    text =
    ''
    #!/usr/bin/env bash
    #
    # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
    #
    # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
    # After this file is installed, restart libvirt.
    # From now on, you can easily add per-guest qemu hooks.
    # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
    # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
    #

    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    MISC="''${@:4}"

    BASEDIR="$(dirname $0)"

    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

    set -e # If a script exits with an error, we should as well.

    # check if it's a non-empty executable file
    if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
    eval \"$HOOKPATH\" "$@"
    elif [ -d "$HOOKPATH" ]; then
    while read file; do
    # check for null string
    if [ ! -z "$file" ]; then
    eval \"$file\" "$@"
    fi
    done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
    fi
    '';
    mode = "0755";
    };

    "libvirt/hooks/kvm.conf" = {
    text =
    ''
    VIRSH_GPU_VIDEO=pci_0000_01_00_0
    VIRSH_GPU_AUDIO=pci_0000_01_00_1
    VIRSH_GPU_USB=pci_0000_01_00_2
    VIRSH_GPU_SERIAL_BUS=pci_0000_01_00_3
    '';
    mode = "0755";
    };

    "libvirt/hooks/qemu.d/win11/prepare/begin/start.sh" = {
    text =
    ''
    #!/usr/bin/env bash
    # Debugging
    exec 19>/home/materus/startlogfile
    BASH_XTRACEFD=19
    set -x

    exec 3>&1 4>&2
    trap 'exec 2>&4 1>&3' 0 1 2 3
    exec 1>/home/materus/startlogfile.out 2>&1



    # Stop display manager
    killall -u materus
    systemctl stop display-manager.service
    killall gdm-x-session
    #systemctl isolate multi-user.target
    sleep 1


    # Load variables we defined
    source "/etc/libvirt/hooks/kvm.conf"

    # Isolate host to core 0
    systemctl set-property --runtime -- user.slice AllowedCPUs=0
    systemctl set-property --runtime -- system.slice AllowedCPUs=0
    systemctl set-property --runtime -- init.scope AllowedCPUs=0



    # Unbind VTconsoles
    for (( i = 0; i < 16; i++))
    do
    if test -x /sys/class/vtconsole/vtcon"''${i}"; then
    if [ "$(grep -c "frame buffer" /sys/class/vtconsole/vtcon"''${i}"/name)" = 1 ]; then
    echo 0 > /sys/class/vtconsole/vtcon"''${i}"/bind
    echo "$DATE Unbinding Console ''${i}"
    fi
    fi
    done

    # Unbind EFI Framebuffer
    echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/unbind

    # Avoid race condition
    sleep 1

    # Unload NVIDIA kernel modules
    modprobe -r nvidia_uvm
    modprobe -r nvidia_drm
    modprobe -r nvidia_modeset
    modprobe -r nvidia
    modprobe -r i2c_nvidia_gpu
    modprobe -r drm_kms_helper
    modprobe -r drm

    # Detach GPU devices from host
    #virsh nodedev-detach $VIRSH_GPU_VIDEO
    #virsh nodedev-detach $VIRSH_GPU_AUDIO
    #virsh nodedev-detach $VIRSH_GPU_USB
    #virsh nodedev-detach $VIRSH_GPU_SERIAL_BUS

    # Load vfio module
    modprobe vfio
    modprobe vfio_pci
    modprobe vfio_iommu_type1
    '';
    mode = "0755";
    };

    "libvirt/hooks/qemu.d/win11/release/end/stop.sh" = {
    text =
    ''
    #!/usr/bin/env bash
    # Debugging
    exec 19>/home/materus/stoplogfile
    BASH_XTRACEFD=19
    set -x

    exec 3>&1 4>&2
    trap 'exec 2>&4 1>&3' 0 1 2 3
    exec 1>/home/materus/stoplogfile.out 2>&1

    # Load variables we defined
    source "/etc/libvirt/hooks/kvm.conf"

    # Unload vfio module
    modprobe -r vfio-pci
    modprobe -r vfio_iommu_type1
    modprobe -r vfio



    modprobe drm
    modprobe drm_kms_helper
    modprobe i2c_nvidia_gpu
    modprobe nvidia
    modprobe nvidia_modeset
    modprobe nvidia_drm
    modprobe nvidia_uvm

    # Attach GPU devices from host
    #virsh nodedev-reattach $VIRSH_GPU_VIDEO
    #virsh nodedev-reattach $VIRSH_GPU_AUDIO
    #virsh nodedev-reattach $VIRSH_GPU_USB
    #virsh nodedev-reattach $VIRSH_GPU_SERIAL_BUS

    #echo "0000:01:00.0" > /sys/bus/pci/drivers/nvidia/bind
    # Bind EFI Framebuffer
    echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

    # Bind VTconsoles
    echo 1 > /sys/class/vtconsole/vtcon0/bind
    #echo 1 > /sys/class/vtconsole/vtcon1/bind


    # Start display manager
    sleep 1
    systemctl start display-manager.service

    # Return host to all cores
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-3
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-3
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-3
    '';
    /*text = ''
    #!/usr/bin/env bash
    reboot
    '';*-/
    mode = "0755";
    };
    "libvirt/vgabios/patched.rom".source = ./vbios.rom;
    }; */
}
