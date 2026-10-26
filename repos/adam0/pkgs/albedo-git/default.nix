{
  # keep-sorted start
  callPackage,
  fetchFromTangled,
  lib,
  makeWrapper,
  symlinkJoin,
  # keep-sorted end
}: let
  pname = "albedo-git";
  version = "0-unstable-2026-10-26";

  src = fetchFromTangled {
    did = "did:plc:l7hhzcbqqvpcquau5waryzdu";
    rev = "b274c034e64263a48961adcdf736f1e0cc838fd6";
    hash = "sha256-e9NVit5m27hJJH5B8FFyT8oSm80lIB0O2qeg0NmycGw=";
  };

  chrome-headless-shell = callPackage ./chrome-headless-shell.nix {};

  # The provide-usage CLI, pinned to the revision the upstream flake uses.
  usageCore = callPackage ./usage-core.nix {};

  render = callPackage ./render.nix {inherit src;};

  server = callPackage ./server.nix {
    inherit
      # keep-sorted start
      chrome-headless-shell
      render
      src
      usageCore
      # keep-sorted end
      ;
  };

  client = callPackage ./client.nix {
    inherit
      # keep-sorted start
      server
      src
      # keep-sorted end
      ;
  };
  package = symlinkJoin {
    inherit
      # keep-sorted start
      pname
      src
      version
      # keep-sorted end
      ;

    paths = [
      # keep-sorted start
      client
      server
      # keep-sorted end
    ];

    nativeBuildInputs = [makeWrapper];

    postBuild =
      (import ./install-notices.nix {inherit pname src;})
      + ''
        rm $out/bin/albedo
        makeWrapper ${client}/bin/albedo $out/bin/albedo --set-default ALBEDO_DAEMON ${server}/bin/albedo-daemon
      '';

    passthru = {
      updateSourceFiles = ["manifest.toml"];
      daemon = server;
      tests.notices = callPackage ./notices-test.nix {
        inherit package;
      };
      inherit
        # keep-sorted start
        client
        render
        server
        usageCore
        # keep-sorted end
        ;
    };

    meta = with lib; {
      # keep-sorted start
      description = "Coding agent daemon with a Charm terminal client";
      homepage = "https://tangled.org/okami.mom/albedo";
      license = licenses.mpl20;
      mainProgram = "albedo";
      platforms = platforms.unix;
      # keep-sorted end
    };
  };
in
  package
