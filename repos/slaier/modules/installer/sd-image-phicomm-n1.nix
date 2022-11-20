{ pkgs, config, ... }:
{
  hardware.deviceTree = {
    enable = true;
    name = "amlogic/meson-gxl-s905d-phicomm-n1.dtb";
    kernelPackage = let kernel = config.boot.kernelPackages.kernel; in
      pkgs.stdenv.mkDerivation {
        name = "dtbs-with-symbols";
        inherit (kernel) src nativeBuildInputs depsBuildBuild;
        patches = (map (patch: patch.patch) kernel.kernelPatches) ++ [
          (pkgs.fetchpatch {
            name = "fix-dtb-of-aml-s905d-phicomm-n1.patch";
            url = "https://raw.githubusercontent.com/yunsur/phicomm-n1/d31bfec8707b5d6a43ef57d1473a887e54f0731a/patch/kernel/arm-64-legacy/fix-dtb-of-aml-s905d-phicomm-n1.patch";
            sha256 = "sha256-KuMYzwGE9bmIGigY/fSz1FPtC8MDnGrFdE+2si/pM1k=";
          })
        ];
        buildPhase = ''
          patchShebangs scripts/*
          substituteInPlace scripts/Makefile.lib \
            --replace 'DTC_FLAGS += $(DTC_FLAGS_$(basetarget))' 'DTC_FLAGS += $(DTC_FLAGS_$(basetarget)) -@'
          make ${pkgs.stdenv.hostPlatform.linux-kernel.baseConfig} ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
          make dtbs ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
        '';
        installPhase = ''
          make dtbs_install INSTALL_DTBS_PATH=$out/dtbs ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
        '';
      };
  };

  system.nixos-generate-config.configuration = ''
    # Edit this configuration file to define what should be installed on
    # your system.  Help is available in the configuration.nix(5) man page
    # and in the NixOS manual (accessible by running ‘nixos-help’).

    { config, pkgs, ... }:

    {
      imports =
        [ # Include the results of the hardware scan.
          ./hardware-configuration.nix
        ];

    $bootLoaderConfig
      # Patch the device tree to get the hardware working.
      hardware.deviceTree = {
        enable = true;
        name = "amlogic/meson-gxl-s905d-phicomm-n1.dtb";
        kernelPackage = let kernel = config.boot.kernelPackages.kernel; in
          pkgs.stdenv.mkDerivation {
            name = "dtbs-with-symbols";
            inherit (kernel) src nativeBuildInputs depsBuildBuild;
            patches = (map (patch: patch.patch) kernel.kernelPatches) ++ [
              (pkgs.fetchpatch {
                name = "fix-dtb-of-aml-s905d-phicomm-n1.patch";
                url = "https://raw.githubusercontent.com/yunsur/phicomm-n1/d31bfec8707b5d6a43ef57d1473a887e54f0731a/patch/kernel/arm-64-legacy/fix-dtb-of-aml-s905d-phicomm-n1.patch";
                sha256 = "sha256-KuMYzwGE9bmIGigY/fSz1FPtC8MDnGrFdE+2si/pM1k=";
              })
            ];
            buildPhase = '''
              patchShebangs scripts/*
              substituteInPlace scripts/Makefile.lib \\
                --replace 'DTC_FLAGS += \$(DTC_FLAGS_\$(basetarget))' 'DTC_FLAGS += \$(DTC_FLAGS_\$(basetarget)) -\@'
              make \''${pkgs.stdenv.hostPlatform.linux-kernel.baseConfig} ARCH="\''${pkgs.stdenv.hostPlatform.linuxArch}"
              make dtbs ARCH="\''${pkgs.stdenv.hostPlatform.linuxArch}"
            ''';
            installPhase = '''
              make dtbs_install INSTALL_DTBS_PATH=\$out/dtbs ARCH="\''${pkgs.stdenv.hostPlatform.linuxArch}"
            ''';
          };
      };

      # Use substituters to speed up access to the cache.
      # nix.settings = {
      #   substituters = [
      #     "https://mirrors.ustc.edu.cn/nix-channels/store"
      #     "https://mirror.nju.edu.cn/nix-channels/store"
      #     "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      #   ];
      #   auto-optimise-store = true;
      # };

      # Enable flake.
      # nix.extraOptions = '''
      #   experimental-features = nix-command flakes
      # ''';

      # networking.hostName = "nixos"; # Define your hostname.
      # Pick only one of the below networking options.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
      # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

      # Set your time zone.
      # time.timeZone = "Europe/Amsterdam";

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password\@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Select internationalisation properties.
      # i18n.defaultLocale = "en_US.UTF-8";
      # console = {
      #   font = "Lat2-Terminus16";
      #   keyMap = "us";
      #   useXkbConfig = true; # use xkbOptions in tty.
      # };

    $xserverConfig

    $desktopConfiguration
      # Configure keymap in X11
      # services.xserver.layout = "us";
      # services.xserver.xkbOptions = {
      #   "eurosign:e";
      #   "caps:escape" # map caps to escape.
      # };

      # Enable CUPS to print documents.
      # services.printing.enable = true;

      # Enable sound.
      # sound.enable = true;
      # hardware.pulseaudio.enable = true;

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      # users.users.alice = {
      #   isNormalUser = true;
      #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      #   packages = with pkgs; [
      #     firefox
      #     thunderbird
      #   ];
      # };

      # List packages installed in system profile. To search, run:
      # \$ nix search wget
      # environment.systemPackages = with pkgs; [
      #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #   wget
      # ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "${config.system.nixos.release}"; # Did you read the comment?

    }
  '';

  users.users.installer = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "installer";
  };

  environment.systemPackages = with pkgs; [
    ethtool
  ];

  services.sshd.enable = true;

  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.nju.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    auto-optimise-store = true;
    flake-registry = "/etc/nix/registry.json";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  sdImage.populateFirmwareCommands = ''
    cp ${pkgs.ubootPhicommN1}/* firmware/
  '';
  sdImage.compressImage = false;
}
