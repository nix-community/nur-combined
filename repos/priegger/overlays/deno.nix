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
          sha256 = "sha256-VRXTv0iL8HJy5Gk4HicmwjNxnMLdfTGkw4bT4Z5pBCA=";
        }
      )
      { };
in
{
  inherit (pkgs) deno;
}
