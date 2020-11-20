self: super:
let
  # https://github.com/NixOS/nixpkgs/pull/100257
  pkgs =
    import
      (
        super.fetchFromGitHub {
          owner = "priegger";
          repo = "nixpkgs";
          rev = "feature/update-bees";
          sha256 = "sha256-f+qRje4xowc3Gxq+1gsxlCmukO/ji0vw3ZjURNadAWc=";
        }
      )
      { };
in
{
  bees = pkgs.bees;
}
