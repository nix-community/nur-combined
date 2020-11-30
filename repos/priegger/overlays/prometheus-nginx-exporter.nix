self: super:
let
  # https://github.com/NixOS/nixpkgs/pull/...
  pkgs =
    import
      (
        super.fetchFromGitHub {
          owner = "priegger";
          repo = "nixpkgs";
          rev = "fix/prometheus-nginx-exporter";
          sha256 = "sha256-lZc4ft+G+hN3SmHzHEixNpRftzI4tU6yH/2bh9ThVBI=";
        }
      )
      { };
in
{
  prometheus-nginx-exporter = pkgs.prometheus-nginx-exporter;
}
