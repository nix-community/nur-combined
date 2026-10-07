{
  callPackage,
  callPackages,
  codex,
  lib,
  channel,
  githubReleaseUpdater ? callPackage ../../lib/github-release-updater.nix { },
  providerPackages ? [ codex ],
  commandLineArgs ? "",
  sources ? (callPackage ./sources.nix { }).${channel},
  cliUnwrapped ? callPackage ./unwrapped.nix {
    pname = "t3code-bin-unwrapped";
    source = sources.cli;
  },
  desktopUnwrapped ? callPackage ./desktop-unwrapped.nix {
    pname = "t3code-desktop-bin-unwrapped";
    source = sources.desktop;
  },
  mkT3code ? callPackage ./wrapper.nix,
  cli ? callPackage ./cli.nix {
    inherit mkT3code providerPackages;
    unwrapped = cliUnwrapped;
  },
  desktop ? callPackage ./desktop.nix {
    inherit mkT3code providerPackages commandLineArgs;
    unwrapped = desktopUnwrapped;
  },
}:

let
  updateArgs = {
    stable = [
      "--attribute"
      "t3code-bin"
      "--tag-pattern"
      "v(\\d+\\.\\d+\\.\\d+)"
    ];
    nightly = [
      "--attribute"
      "t3code-nightly-bin"
      "--tag-pattern"
      "v(\\d+\\.\\d+\\.\\d+-nightly\\.\\d{8}\\.\\d+)"
      "--prerelease"
    ];
  };

  package = cli.overrideAttrs (old: {
    passthru = old.passthru // {
      inherit cli desktop mkT3code;
      tests = callPackages ./tests.nix { t3code = package; };
      updateScript = [
        (lib.getExe githubReleaseUpdater)
        "--owner"
        "pingdotgg"
        "--repo"
        "t3code"
      ]
      ++ updateArgs.${channel}
      ++ [
        "--"
        "--override-filename=pkgs/t3code-bin/sources.nix"
        "--subpackage=desktop"
      ];
    };
  });
in
package
