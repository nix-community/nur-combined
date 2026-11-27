{
  # keep-sorted start
  callPackage,
  fetchFromTangled,
  lib,
  makeBinaryWrapper,
  symlinkJoin,
  withPhoton ? true,
  withWeb ? true,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    optionalAttrs
    optionalString
    optionals
    # keep-sorted end
    ;

  pname = "albedo-git";
  version = "0-unstable-2026-11-27";

  src = fetchFromTangled {
    did = "did:plc:l7hhzcbqqvpcquau5waryzdu";
    rev = "bad7623dffc8c09809f1be87fce7d91c0352af23";
    hash = "sha256-Aj/bRz35cgmrffsygRDEa2ixVvzNIbkEVcgsMItVi34=";
  };

  chrome-headless-shell = callPackage ./chrome-headless-shell.nix {};

  # The provide-usage CLI, pinned to the revision the upstream flake uses.
  usageCore = callPackage ./usage-core.nix {};

  render = callPackage ./render.nix {inherit src;};

  photon = callPackage ./photon.nix {inherit src;};

  web = callPackage ./web.nix {inherit src;};

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

    paths =
      [
        # keep-sorted start
        client
        server
        # keep-sorted end
      ]
      ++ optionals withPhoton [photon];

    nativeBuildInputs = [makeBinaryWrapper];

    postBuild =
      (import ./install-notices.nix {inherit pname src;})
      + ''
        for name in albedo albedo-{acp,tui,web}; do
          rm $out/bin/$name
          makeBinaryWrapper ${client}/bin/$name $out/bin/$name --inherit-argv0 --set-default ALBEDO_DAEMON ${server}/bin/albedo-daemon \
            ${optionalString withPhoton "--prefix PATH : ${photon}/bin"} \
            ${optionalString withWeb "--set-default ALBEDO_WEB_DIST ${web}"}
        done
        makeBinaryWrapper ${client}/libexec/albedo/albedo-server $out/bin/albedo-server --set-default ALBEDO_DAEMON ${server}/bin/albedo-daemon
      '';

    passthru =
      {
        updateSourceFiles = ["apps/albedo/manifest.toml"];
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
      }
      // optionalAttrs withPhoton {inherit photon;}
      // optionalAttrs withWeb {inherit web;};

    meta = with lib; {
      # keep-sorted start
      description = "Coding agent daemon with a Charm terminal client";
      homepage = "https://tangled.org/okami.mom/albedo";
      license = import ./license.nix {inherit lib;};
      mainProgram = "albedo";
      platforms = platforms.unix;
      # keep-sorted end
    };
  };
in
  package
