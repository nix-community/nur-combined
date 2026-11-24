{
  pkgs,
}:

let
  inherit (pkgs.lib)
    hasAttrByPath
    importTOML
    optionalString
    substring
    warnOnInstantiate
    ;

  upstreamStatus = importTOML ./upstream-status.toml;

  packages = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pkgs.newScope packages;
    directory = ./packages;
  };

  formatRelease =
    release:
    let
      s = toString release;
    in
    "${substring 0 2 s}.${substring 2 2 s}";
  warnIfUpstreamed =
    name: pkg:
    let
      us = upstreamStatus.${name};
    in
    if us.merged or false then
      let
        replacementAttributePath = us.replacementAttributePath or [ name ];
        replacementMessage =
          us.replacementMessage or "Please replace `pkgs.nur.repos.ilkecan.${name}` with `pkgs.${name}`.";
        msg = "${optionalString (hasAttrByPath replacementAttributePath pkgs) "${replacementMessage}\n"}`pkgs.nur.repos.ilkecan.${name}` has been upstreamed to nixpkgs and the NUR package will be removed after NixOS ${formatRelease us.removeAfter} is EOL.";
      in
      warnOnInstantiate msg pkg
    else
      pkg;
in
# NUR evaluates the repo without `pkgs` to reach its modules, so the attribute
# names must not depend on it. Every entry in ./packages is a directory, for
# which `packagesFromDirectoryRecursive` uses the directory name as is.
builtins.mapAttrs (name: _: warnIfUpstreamed name packages.${name}) (builtins.readDir ./packages)
