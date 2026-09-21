{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  hidapi,
}:

stdenv.mkDerivation {
  pname = "gloriousctl";
  version = "0-unstable-2026-03-25";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "enkore";
    repo = "gloriousctl";
    rev = "ad5772fccbfffd85e69c94d17a2228191480e19f";
    hash = "sha256-lqFw6GZ5THp8kAZVxtYqoqYeoncXcr1pxEmlBCsGu6w=";
  };

  buildInputs = [
    hidapi
  ];

  installPhase = ''
    install -Dm755 gloriousctl $out/bin/gloriousctl
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=latest" ]; };

  meta = {
    description = "A utility to adjust the settings of Model O/D mice on Linux/BSD";
    homepage = "https://github.com/enkore/gloriousctl";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "gloriousctl";
    platforms = lib.platforms.all;
  };
}
