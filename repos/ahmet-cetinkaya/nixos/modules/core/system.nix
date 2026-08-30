{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      icu
      libnotify
    ];

    # Forces propagation of PKG_CONFIG_PATH to expose development headers and pkg-config
    # metadata for GTK/GLib stack; required by build systems that search for dependencies.
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

    # pathsToLink merges .dev outputs into environment so pkg-config and C headers are discoverable.
    pathsToLink = ["/lib/pkgconfig" "/include"];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Let dynamically linked binaries outside the Nix store find these shared libraries.
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

  # Preserve the release used for initial installation; do not bump during upgrades.
  system.stateVersion = "26.05";
}
