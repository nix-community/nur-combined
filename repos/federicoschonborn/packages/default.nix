{ pkgs ? import <nixpkgs> { } }: rec {
  arkade = pkgs.libsForQt5.callPackage ./arkade.nix { };
  atoms = pkgs.callPackage ./atoms.nix { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./atoms-core.nix { };
  blurble = pkgs.callPackage ./blurble.nix { };
  boulder = pkgs.callPackage ./boulder.nix { inherit libmoss; };
  brisk-menu = pkgs.callPackage ./brisk-menu.nix { };
  bsdutils = pkgs.callPackage ./bsdutils.nix { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./cargo-aoc.nix { };
  casaos = pkgs.callPackage ./casaos.nix { };
  chess-clock = pkgs.callPackage ./chess-clock.nix { };
  devtoolbox = pkgs.callPackage ./devtoolbox.nix { };
  eloquens = pkgs.libsForQt5.callPackage ./eloquens.nix { };
  fastfetch = pkgs.callPackage ./fastfetch.nix { inherit fastfetch; };
  fastfetchFull = pkgs.lib.warn "fastfetchFull has been renamed to fastfetch.full" fastfetch.full;
  fielding = pkgs.libsForQt5.callPackage ./fielding.nix { };
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme.nix { };
  flyaway = pkgs.callPackage ./flyaway.nix { wlroots = wlroots_0_16; };
  francis = pkgs.libsForQt5.callPackage ./francis.nix { kirigami-addons = kirigami-addons_0_10; };
  game-of-life = pkgs.callPackage ./game-of-life.nix { };
  gradebook = pkgs.callPackage ./gradebook.nix { };
  gtatool = pkgs.callPackage ./gtatool { inherit gtatool; inherit libgta teem; };
  gtatoolFull = pkgs.lib.warn "gtatoolFull has been renamed to gtatool.full" gtatool.full;
  kommit = pkgs.libsForQt5.callPackage ./kommit.nix { };
  licentia = pkgs.libsForQt5.callPackage ./licentia.nix { kirigami-addons = kirigami-addons_0_10; };
  libgta = pkgs.callPackage ./libgta.nix { };
  libtgd = pkgs.callPackage ./libtgd.nix { inherit libtgd; inherit libgta; };
  libtgdFull = pkgs.lib.warn "libtgdFull has been renamed to libtgd.full" libtgd.full;
  libxo = pkgs.callPackage ./libxo { };
  libzypp = pkgs.callPackage ./libzypp.nix { libsolv = libsolv-libzypp; };
  liquidshell = pkgs.libsForQt5.callPackage ./liquidshell.nix { };
  marknote = pkgs.libsForQt5.callPackage ./marknote.nix { };
  metronome = pkgs.callPackage ./metronome.nix { };
  morewaita = pkgs.callPackage ./morewaita.nix { };
  moss = pkgs.callPackage ./moss.nix { inherit libmoss; };
  moss-container = pkgs.callPackage ./moss-container.nix { inherit libmoss; };
  mucalc = pkgs.callPackage ./mucalc.nix { };
  notae = pkgs.libsForQt5.callPackage ./notae.nix { };
  opensurge = pkgs.callPackage ./opensurge.nix { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./qv.nix { inherit libtgd; };
  rollit = pkgs.callPackage ./rollit.nix { };
  share-preview = pkgs.callPackage ./share-preview.nix { };
  srb2p = pkgs.callPackage ./srb2p { };
  surgescript = pkgs.callPackage ./surgescript.nix { };
  teem = pkgs.callPackage ./teem.nix { inherit teem; };
  teemFull = pkgs.lib.warn "teemFull has been renamed to teem.full" teem.full;
  teemExperimental = pkgs.lib.warn "teemExperimental has been renamed to teem.experimental" teem.experimental;
  teemExperimentalFull = pkgs.lib.warn "teemExperimentalFull has been renamed to teem.experimentalFull" teem.experimentalFull;
  telegraph = pkgs.callPackage ./telegraph.nix { };
  textsnatcher = pkgs.callPackage ./textsnatcher.nix { };
  thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme.nix { };
  tuba = pkgs.callPackage ./tuba.nix { };
  upkg = pkgs.callPackage ./upkg.nix { };
  xdg-terminal-exec = pkgs.callPackage ./xdg-terminal-exec.nix { };
  zypper = pkgs.callPackage ./zypper.nix { inherit libzypp; };

  apx_v2 = pkgs.apx.overrideAttrs (oldAttrs: {
    version = "2.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "Vanilla-OS";
      repo = "apx";
      rev = "d51bcf0680498a99a0835222838f1383ba8510ef";
      hash = "sha256-lGsl6Tbo5AUpNeWbbfMUS8H+Gmt66tqkyxclXiC2I0Y=";
    };
    # Same as Nixpkgs' but without the manpage copying.
    postInstall = ''
      mkdir -p $out/etc/apx

      cat > "$out/etc/apx/config.json" <<EOF
        {
          "containername": "apx_managed",
          "image": "docker.io/library/ubuntu",
          "pkgmanager": "apt",
          "distroboxpath": "${pkgs.distrobox}/bin/distrobox"
        }
      EOF

      wrapProgram $out/bin/apx --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.docker pkgs.distrobox ]}
    '';
    passthru = {
      updateScript = pkgs.unstableGitUpdater { };
    };
    meta = oldAttrs.meta // {
      platforms = pkgs.lib.platforms.linux;
    };
  });

  libsolv-libzypp = pkgs.libsolv.overrideAttrs (oldAttrs: {
    pname = "libsolv-libzypp";
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DENABLE_HELIXREPO=true"
    ];
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (for libzypp)";
    };
  });

  libmoss = pkgs.fetchFromGitHub {
    name = "libmoss";
    owner = "FedericoSchonborn";
    repo = "libmoss";
    rev = "fc143087d0d7b124a3dfd7c5e635223d9b12064a";
    hash = "sha256-oOm2luvqIr41ehDbfQUEGrJ4LdrngIo0RJ1OqGHD3d4=";
  };

  wlroots_0_16 = pkgs.wlroots.overrideAttrs (prev: rec {
    version = "0.16.2";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "wlroots";
      repo = "wlroots";
      rev = version;
      hash = "sha256-JeDDYinio14BOl6CbzAPnJDOnrk4vgGNMN++rcy2ItQ=";
    };
    buildInputs = prev.buildInputs ++ [ pkgs.hwdata ];
  });

  kirigami-addons_0_10 = pkgs.libsForQt5.kirigami-addons.overrideAttrs (oldAttrs: rec {
    version = "0.10.0";
    src = pkgs.fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "libraries";
      repo = "kirigami-addons";
      rev = "v${version}";
      hash = "sha256-wwc0PCY8vNCmmwfIYYQhQea9AYkHakvTaERtazz8npQ=";
    };
    meta = oldAttrs.meta // (with pkgs.lib; {
      platforms = platforms.linux;
    });
  });
}
