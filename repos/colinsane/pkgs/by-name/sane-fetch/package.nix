{
  python3,
  static-nix-shell,
  tor,
}:
static-nix-shell.mkPython3 {
  pname = "sane-fetch";
  srcRoot = ./.;
  pkgs = {
    inherit tor;
    "python3.pkgs.aiohttp-socks" = python3.pkgs.aiohttp-socks;
    "python3.pkgs.crawl4ai" = python3.pkgs.crawl4ai;
    "python3.pkgs.mcp" = python3.pkgs.mcp;
    "python3.pkgs.pypdf" = python3.pkgs.pypdf;
    "python3.pkgs.stem" = python3.pkgs.stem;
    "tor.geoip" = tor.geoip;
  };
  preInstallCheck = ''
    export HOME=$(mktemp -d)
  '';
}
