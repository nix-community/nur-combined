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
  version = "0-unstable-2026-10-14";

  src = fetchFromTangled {
    did = "did:plc:l7hhzcbqqvpcquau5waryzdu";
    rev = "28c0a7596ed0a378351a09aaf9525c2e3e1bfc1a";
    hash = "sha256-SnUgWyoTBVkxfqHhcAl9JoJ3HXEL3mAm2qqLnxQ5mJQ=";
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
in
  symlinkJoin {
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

    postBuild = ''
      rm $out/bin/albedo
      makeWrapper ${client}/bin/albedo $out/bin/albedo --set-default ALBEDO_DAEMON ${server}/bin/albedo-daemon
    '';

    passthru = {
      daemon = server;
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
      license = licenses.wtfpl;
      mainProgram = "albedo";
      platforms = platforms.unix;
      # keep-sorted end
    };
  }
