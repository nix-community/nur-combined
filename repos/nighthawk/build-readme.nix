{
  pkgs ? import <nixpkgs> { },
}:

with builtins;
let
  lib = pkgs.lib;
  nurAttrs = import ./default.nix { inherit pkgs; };
  isReserved =
    n:
    elem n [
      "lib"
      "overlays"
      "modules"
      "hmModules"
    ];
  isAlias = n: false;
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

    ![Build and populate cache](https://github.com/CDotNightHawk/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-nighthawk-blue.svg)](https://nighthawk.cachix.org)

    My personal [NUR](https://github.com/nix-community/NUR) repository.

    NUR link: https://nur.nix-community.org/repos/nighthawk/

    ## Packages

    | Name | Attr | Description |
    | --- | --- | --- |
    ${makeTableFilterAttrs "" nurAttrs}

    ## Overlay

    The default overlay will add all the packages above in the `pkgs.nightpkg` namespace, e.g. `pkgs.nightpkg.something`.

    There is a NixOS module to automatically add this overlay as `nixosModules.overlay`. This module can also be used with Home Manager and nix-darwin.

    ## Home Manager modules

    ### services.lnshot.enable

    Enables the lnshot daemon to automatically link Steam screenshots.

    ### services.lnshot.picturesName

    Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".
  '';
in
pkgs.mkShellNoCC {
  name = "night-nur-readme-builder";
  shellHook = ''
    set -x
    cp ${text} README.md
    set +x
    exit
  '';
}
