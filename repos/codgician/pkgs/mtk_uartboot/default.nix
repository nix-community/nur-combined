{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "mtk_uartboot";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "981213";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mwwm2TVBfOEqvQIP0Vl4Q2SkcZxX1JP7rShmjaY+pWE=";
  };

  cargoHash = "sha256-uS4ESPWMJ1JIKvszA3oVlBIHoG2WzT5+W/9KCjKk+6s=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A third-party tool to load and execute binaries over UART for Mediatek SoCs";
    homepage = "https://github.com/981213/mtk_uartboot";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
}
