{ pkgs }:

# Published as nur.repos.AndrewKvalheim (https://nur.nix-community.org/repos/andrewkvalheim/)
rec {
  hmModules = {
    nixpkgs-issue-55674 = import ./packages/nixpkgs-issue-55674.nix;
    xcompose = import ./packages/xcompose.nix;
  };

  modules = {
    nixpkgs-issue-55674 = import ./packages/nixpkgs-issue-55674.nix;
    nixpkgs-issue-163080 = import ./packages/nixpkgs-issue-163080.nix;
  };

  lib = {
    inherit (import ./common/resources/lib.nix { inherit (pkgs) lib; })
      chebyshev
      chebyshevWithDomain
      contrastRatio
      linearRgbToRgb
      oklchToCss
      oklchToLinearRgb
      rgbToHex
      sgr;
  };

  apex = pkgs.callPackage ./packages/apex.nix { };
  blocky-ui = pkgs.callPackage ./packages/blocky-ui.nix { };
  buildJosmPlugin = pkgs.callPackage ./packages/buildJosmPlugin.nix { };
  cavif = pkgs.callPackage ./packages/cavif.nix { };
  ch57x-keyboard-tool = pkgs.callPackage ./packages/ch57x-keyboard-tool.nix { };
  co2monitor = pkgs.callPackage ./packages/co2monitor.nix { };
  decompiler-mc = pkgs.callPackage ./packages/decompiler-mc.nix { };
  dmarc-report-notifier = (pkgs.callPackage ./packages/dmarc-report-notifier.nix {
    python3Packages = (pkgs.python3.override {
      packageOverrides = resolved: pythonPackages: {
        # Pending NixOS/nixpkgs#337081
        msgraph-core = pkgs.lib.warnIfNot pkgs.python3Packages.parsedmarc.meta.broken "python3Packages.parsedmarc is no longer broken"
          (pkgs.lib.findFirst (p: p.pname == "msgraph-core") null pkgs.parsedmarc.requiredPythonModules);
        # Pending NixOS/nixpkgs#352871
        opensearch-py = pythonPackages.opensearch-py.overridePythonAttrs (opensearch-py: {
          disabledTests = opensearch-py.disabledTests ++ [
            "test_basicauth_in_request_session"
            "test_callable_in_request_session"
            "test_security_plugin"
          ];
        });
        # Pending NixOS/nixpkgs#357642 (followup to NixOS/nixpkgs#345326)
        parsedmarc = pythonPackages.parsedmarc.overridePythonAttrs (parsedmarc: {
          propagatedBuildInputs = parsedmarc.propagatedBuildInputs ++ [ resolved.pygelf ];
        });
        # Pending NixOS/nixpkgs#357642 (followup to NixOS/nixpkgs#345326)
        pygelf = pkgs.lib.warnIf (pythonPackages ? pygelf) "python3Packages.pygelf is no longer missing"
          pythonPackages.buildPythonPackage
          rec {
            pname = "pygelf";
            version = "0.4.2";
            pyproject = true;
            src = pythonPackages.fetchPypi {
              inherit pname version;
              hash = "sha256-0LuPRf9kipoYdxP0oFwJ9oX8uK3XsEu3Rx8gBxvRGq0=";
            };
            build-system = [ pythonPackages.setuptools ];
          };
      };
    }).pkgs;
  }).overrideAttrs (d: {
    meta = d.meta // {
      broken = pkgs.lib.versionAtLeast pkgs.python3Packages.httpx.version "0.28"; # Dependency of msgraph-core
    };
  });
  fastnbt-tools = pkgs.callPackage ./packages/fastnbt-tools.nix { };
  fediblockhole = pkgs.callPackage ./packages/fediblockhole.nix { };
  git-diff-image = pkgs.callPackage ./packages/git-diff-image.nix { };
  gpx-reduce = pkgs.callPackage ./packages/gpx-reduce.nix { };
  iptables_exporter = pkgs.callPackage ./packages/iptables_exporter.nix { };
  josm-imagery-used = pkgs.callPackage ./packages/josm-imagery-used.nix { inherit buildJosmPlugin; };
  little-a-map = pkgs.callPackage ./packages/little-a-map.nix { };
  mark-applier = pkgs.callPackage ./packages/mark-applier.nix { };
  meshtastic-url = pkgs.callPackage ./packages/meshtastic-url.nix { };
  minemap = pkgs.callPackage ./packages/minemap.nix { };
  mqtt-connect = pkgs.callPackage ./packages/mqtt-connect.nix { };
  mqtt-protobuf-to-json = pkgs.callPackage ./packages/mqtt-protobuf-to-json.nix { };
  nbt-explorer = pkgs.callPackage ./packages/nbt-explorer.nix { };
  pngquant-interactive = pkgs.callPackage ./packages/pngquant-interactive.nix { };
  spf-check = pkgs.callPackage ./packages/spf-check.nix { };
  spf-tree = pkgs.callPackage ./packages/spf-tree.nix { };
  tile-stitch = pkgs.callPackage ./packages/tile-stitch.nix { };
  zsh-completion-sync = pkgs.callPackage ./packages/zsh-completion-sync.nix { };
}
