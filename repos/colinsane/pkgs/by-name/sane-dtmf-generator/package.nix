{
  static-nix-shell,
  python3,
}:
static-nix-shell.mkPython3 {
  pname = "sane-dtmf-generator";
  srcRoot = ./.;
  pkgs = {
    "python3.pkgs.numpy" = python3.pkgs.numpy;
    "python3.pkgs.scipy" = python3.pkgs.scipy;
  };
}
