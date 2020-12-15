self: super:
let
  # https://github.com/NixOS/nixpkgs/pull/104674
  pkgs =
    import
      (
        self.fetchFromGitHub {
          owner = "06kellyjac";
          repo = "nixpkgs";
          rev = "deno";
          sha256 = "sha256-EBoGHe7mWDywTI/BjdDXZj64MFnjQehjRjm1FJrXE8o=";
        }
      )
      { };
in
{
  inherit (pkgs) deno;
}
