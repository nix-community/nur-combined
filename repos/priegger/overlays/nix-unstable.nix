self: super:
let
  # https://github.com/NixOS/nixpkgs/pull/104289
  pkgsNixUnstable =
    import
      (
        super.fetchFromGitHub {
          owner = "hercules-ci";
          repo = "nixpkgs";
          rev = "update-nixUnstable-2020-11-19";
          sha256 = "sha256-QfBMusvXlTwLHaUvHckSDrBOwlTGCEp2gcofnFys8mg=";
        }
      )
      { };
in
{
  nixUnstable = pkgsNixUnstable.nixUnstable;
}
