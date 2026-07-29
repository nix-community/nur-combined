{
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-fetch";
  srcRoot = ./.;
  pkgs = {
    "python3.pkgs.crawl4ai" = python3.pkgs.crawl4ai;
    "python3.pkgs.mcp" = python3.pkgs.mcp;
    "python3.pkgs.pypdf" = python3.pkgs.pypdf;
  };
  preInstallCheck = ''
    export HOME=$(mktemp -d)
  '';
}
