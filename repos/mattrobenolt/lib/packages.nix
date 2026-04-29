{ lib }:

let
  readJSON = path: builtins.fromJSON (builtins.readFile path);
  replaceDot = builtins.replaceStrings [ "." ] [ "_" ];

  goVersions = readJSON ../pkgs/go-bin/versions.json;
  goHashes = readJSON ../pkgs/go-bin/hashes.json;
  zedVersions = readJSON ../pkgs/zed/versions.json;
  zedHashes = readJSON ../pkgs/zed/hashes.json;

  makeGo =
    pkgs: majorMinor:
    let
      version = goVersions.${majorMinor};
      hashes = goHashes.${version};
    in
    pkgs.callPackage ../pkgs/go-bin/package.nix { inherit version hashes; };

  latestGoVersion = builtins.head (
    builtins.sort (a: b: a > b) (builtins.filter (v: v != "next") (builtins.attrNames goVersions))
  );

  goPackageNames = map (majorMinor: "go-bin_" + replaceDot majorMinor) (
    builtins.attrNames goVersions
  );

  goPackages =
    pkgs:
    builtins.listToAttrs (
      map (majorMinor: {
        name = "go-bin_" + replaceDot majorMinor;
        value = makeGo pkgs majorMinor;
      }) (builtins.attrNames goVersions)
    )
    // {
      go-bin = makeGo pkgs latestGoVersion;
    };

  zedPackage =
    pkgs: channel:
    let
      version = zedVersions.${channel};
      hashes = zedHashes.${version};
    in
    pkgs.callPackage ../pkgs/zed/package.nix { inherit version hashes channel; };

  overlay =
    _final: prev:
    goPackages prev
    // {
      uvShellHook = prev.callPackage ../pkgs/uv/venv-shell-hook.nix { };
      inbox = prev.callPackage ../pkgs/inbox/package.nix { };
      zigdoc = prev.callPackage ../pkgs/zigdoc/package.nix { };
      ziglint = prev.callPackage ../pkgs/ziglint/package.nix { };
      tracy = prev.callPackage ../pkgs/tracy/package.nix { };
      zed = zedPackage prev "stable";
      zed-preview = zedPackage prev "preview";
    };

in
{
  inherit goPackageNames overlay;

  packagesFor =
    pkgs:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = pkgs.${name};
      }) goPackageNames
    )
    // {
      inherit (pkgs)
        go-bin
        uvShellHook
        inbox
        zigdoc
        ziglint
        tracy
        ;
      default = pkgs.ziglint;
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      inherit (pkgs) zed zed-preview;
    };
}
