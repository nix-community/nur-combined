{
  pkgs ? import <nixpkgs> { },
}:

with builtins;
let
  lib = pkgs.lib;
  nurAttrs = import ./default.nix { inherit pkgs; };
  isAlias = n: n == "3dstool" || n == "3dslink";
  isReserved =
    n:
    elem n [
      "lib"
      "overlays"
      "modules"
      "hmModules"
    ];
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  hasKnownVulns = p: p.meta ? knownVulnerabilities && (length p.meta.knownVulnerabilities != 0);
  strikeIfKnownVulns = p: text: if hasKnownVulns p then "~~${text}~~" else text;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  filterAttrs =
    attrs:
    listToAttrs (
      map (n: nameValuePair n attrs.${n}) (filter (n: (!isReserved n) && (!isAlias n)) (attrNames attrs))
    );

  makeTable =
    prefix: attrs:
    let
      realpfx = if prefix == "" then "" else "${prefix}.";
    in
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        k: v:
        "| ${
          let
            name = (if (v.meta ? homepage) then "[${v.name}](${v.meta.homepage})" else v.name);
          in
          strikeIfKnownVulns v name
        } | ${
          strikeIfKnownVulns v (replaceStrings [ "_" ] [ "\\_" ] "${realpfx}${k}")
        } | ${strikeIfKnownVulns v v.meta.description} |"
      ) attrs
    );
  makeTableFilterAttrs = prefix: attrs: makeTable prefix (filterAttrs attrs);

  text = pkgs.writeText "README.md" ''
    # nur-packages

    ![Build and populate cache](https://github.com/ihaveamac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-ihaveahax-blue.svg)](https://ihaveahax.cachix.org)

    My personal [NUR](https://github.com/nix-community/NUR) repository.

    Darwin/macOS builds are manually pushed by me to cachix occasionally. Usually when I also update flake.lock.

    NUR link: https://nur.nix-community.org/repos/ihaveamac/

    ## Packages

    | Name | Attr | Description |
    | --- | --- | --- |
    ${makeTableFilterAttrs "" nurAttrs}

    ## Overlay

    The default overlay will add all the packages above in the `pkgs.hax` namespace, e.g. `pkgs.hax.save3ds`.

    There is a NixOS module to automatically add this overlay as `nixosModules.overlay`. This module can also be used with Home Manager and nix-darwin.

    ## Home Manager modules

    ### services.lnshot.enable

    Enables the lnshot daemon to automatically link Steam screenshots.

    ### services.lnshot.picturesName

    Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".

    ### services.lnshot.singleUserID64

    User to read screenshots from. Setting this will skip creating user-specific folders in the pictures folder.
  '';
in
pkgs.mkShellNoCC {
  name = "hax-nur-readme-builder";
  shellHook = ''
    set -x
    cp ${text} README.md
    set +x
    exit
  '';
}
