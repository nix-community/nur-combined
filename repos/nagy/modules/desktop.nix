{
  config,
  pkgs,
  lib,
  ...
}:

let
  self = import ../. { inherit pkgs; };
in
{

  services.xserver = {
    enable = true;
  };

  environment.sessionVariables.XAUTHORITY = "$" + "{XDG_RUNTIME_DIR}/Xauthority";

  # Almost all hosts should have this keymap
  console.keyMap = lib.mkDefault "de";

  # non-root access to the firmware of QMK keyboards
  # hardware.keyboard.qmk.enable = true;

  boot.kernelParams = [
    # https://github.com/lamikr/rocm_sdk_builder/issues/257#issuecomment-3355223605
    "amdgpu.cwsr_enable=0"
  ];

  boot.kernel.sysctl = {
    # This allows a special scape key: alt+print+<key>
    # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    "kernel.sysrq" = 1;
  };

  console.useXkbConfig = true;

  environment.systemPackages = [
    pkgs.xcursorthemes
    pkgs.xwininfo
    pkgs.scrot
    self.nsxivBigThumbs
    pkgs.xclip
    pkgs.pulsemixer
    pkgs.poppler-utils # pdf utils
    pkgs.yt-dlp
    (
      (pkgs.pass.override {
        x11Support = false;
      }).withExtensions
      (exts: [
        exts.pass-otp
      ])
    )
    pkgs.age
    self.passage-with-otp
    pkgs.ssh-to-age
    (pkgs.zbar.override {
      withXorg = false;
      enableVideo = false;
    })
    pkgs.ffmpeg_7-full
    pkgs.pandoc
    # Spelling
    (pkgs.aspellWithDicts (ps: [
      ps.en
      ps.de
    ]))
    # for jinx-mode to set DICPATH
    pkgs.hunspellDicts.en-us
    pkgs.hunspellDicts.de-de
    pkgs.gh

    (pkgs.redshift.override { withGeolocation = false; })
  ]
  ++ (lib.optionals config.documentation.dev.enable [
    pkgs.man-pages
    pkgs.glibcInfo # info files for gnu glibc
    pkgs.csvkit
  ]);

  services.xserver = {
    dpi = lib.mkDefault 192;
    # Configure X11 window manager
    displayManager.startx.enable = true;
    enableTearFree = true;
    # logFile = "/dev/null"; # the default
    # windowManager.exwm.enable = true;
    # videoDrivers = [ "amdgpu" ];
    excludePackages = [ pkgs.xterm ];
    # https://askubuntu.com/questions/366308/how-to-make-xset-s-off-survive-a-reboot-12-04
    serverFlagsSection = ''
      Option "BlankTime" "5"
    '';
    # does not work yet
    # autoRepeatDelay = 260;
    # autoRepeatInterval = 40;
  };

  environment.sessionVariables = {
    # Zwingt ROCm die gfx1103 wie eine unterstützte gfx1100 RDNA3 Karte zu behandeln
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    # https://github.com/ggml-org/llama.cpp/pull/12934/changes
    GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1";
  };

  # for wayland compositors
  environment.sessionVariables.XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;

  services.pulseaudio = {
    enable = lib.mkDefault true;
  };

  services.pipewire = {
    enable = lib.mkForce false;
  };

  programs.wireshark = {
    enable = true;
    # package = if config.services.xserver.enable then pkgs.wireshark else pkgs.wireshark-cli;
    # soon  https://github.com/NixOS/nixpkgs/pull/379179
    # usbmon = true;
  };

  environment.etc."X11/Xresources".text = ''
    *.background: #000000
    *.foreground: #ffffff
    Xcursor.size: 48
    Xcursor.theme: whiteglass
  '';

  environment.extraOutputsToInstall = [
    "dev"
    "bin"
    "info"
    "man"
    "devdoc"
    "out"
    "lib"
  ];

  users.users.user.extraGroups = [
    "video"
    "render"
  ];

  environment.etc."X11/xinit/xinitrc".text = ''
    set -e
    xset r rate 260 40
    xsetroot -cursor_name left_ptr # mostly used for Tauri applications
    [[ -f /etc/X11/Xresources ]] && xrdb /etc/X11/Xresources
    ${pkgs.unclutter-xfixes}/bin/unclutter &
    exec emacs
  '';

  # programs.gnupg = {
  #   # socket activation does not seem to be used. gnupg is starting an agent itself.
  #   # more info: https://discourse.nixos.org/t/how-to-make-gpg-use-the-agent-from-programs-gnupg-agent/11834/2
  #   # but also seems to be used. idk.
  #   # package = gnupg.override { guiSupport = false; };
  #   agent.enable = true;
  #   agent.settings = {
  #     default-cache-ttl = 34560000;
  #     max-cache-ttl = 34560000;
  #   };
  # };

  # Too large closure size
  services.speechd.enable = lib.mkForce false;

  # https://doc.qt.io/qt-6/highdpi.html#platform-details
  environment.sessionVariables.QT_USE_PHYSICAL_DPI = "1"; # for qt6
  # environment.sessionVariables.QT_SCALE_FACTOR = "2"; # for qutebrowser
}
