self: super:
let
  # https://github.com/NixOS/nixpkgs/pull/100257
  pkgs =
    import
      (
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "752b6a95db93f03d6901304f760bd452b4b7db41"; # nixpkgs-unstable as of 2020-11-30
          sha256 = "sha256-hY9Dq8fIK/sDmLgXzhoQnqvwEV2jK2Yv6anjJBeAfZs=";
        }
      )
      { };
in
{
  bees = pkgs.bees;
}
