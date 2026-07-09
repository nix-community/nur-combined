{pkgs, config, ...}: {
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    # exclusive_caps=1 lets OBS and browsers detect the loopback as a webcam;
    # video_nr=2 pins it to /dev/video2 so it is independent of probe order.
    extraModprobeConfig = ''
      options v4l2loopback video_nr=2 card_label=AndroidCam exclusive_caps=1
    '';
  };

  environment = {
    systemPackages = with pkgs; [
      icu
    ];

    # Forces propagation of PKG_CONFIG_PATH
    extraInit = ''
      export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" [
        pkgs.gtk3.dev
        pkgs.glib.dev
        pkgs.pango.dev
        pkgs.cairo.dev
        pkgs.gdk-pixbuf.dev
        pkgs.atk.dev
        pkgs.at-spi2-atk.dev
        pkgs.harfbuzz.dev
        pkgs.libsecret.dev
      ]}"
    '';

    pathsToLink = ["/lib/pkgconfig" "/include"];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      gtk3
      glib
      pango
      cairo
      gdk-pixbuf
      atk
      at-spi2-atk
      harfbuzz
      libglvnd
      mesa
      libsecret
      libwebp
      jsoncpp
      libuuid
      libxkbcommon
      expat
      libgcrypt
      libgpg-error
      lz4
      sqlite
      stdenv.cc.cc
      zlib
      icu
    ];
  };

  system.stateVersion = "26.05";
}
