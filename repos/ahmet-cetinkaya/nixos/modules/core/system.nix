{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

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
