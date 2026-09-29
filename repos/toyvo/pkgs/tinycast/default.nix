{
  pkgs,
  ...
}:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  # tinycast only exists in recent nixpkgs; on older channels (e.g.
  # nixos-26.05) there is nothing to override, so expose no packages instead
  # of failing the whole NUR evaluation (`nix-env -f .`, `ci.nix`).
  mkTinycast =
    version: hash:
    pkgs.tinycast.overrideAttrs {
      inherit version;
      src = pkgs.fetchurl {
        url = "https://github.com/abue-ammar/tinycast/releases/download/v${version}/Tinycast-${version}.dmg";
        inherit hash;
      };
    };
in
if !(pkgs ? tinycast) then
  { }
else
  {
    tinycast = mkTinycast versions.stable.version versions.stable.hash;
    tinycast-beta = mkTinycast versions.beta.version versions.beta.hash;
  }
