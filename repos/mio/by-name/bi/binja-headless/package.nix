{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3Packages,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "binja-headless";
  version = "0-unstable-2025-02-13";

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "binja-headless";
    rev = "e6ab5adb2188efd27c3485fd014125c8b9a2648b";
    hash = "sha256-JBW4iUwK1LqF9OuohgbX4tN5mnUsCj6e7KLZjijCnxc=";
  };

  propagatedBuildInputs = [
    python3Packages.rpyc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/binaryninja/plugins/binja-headless
    cp -r * $out/lib/binaryninja/plugins/binja-headless/

    runHook postInstall
  '';

  meta = {
    description = "Headless Binary Ninja plugin";
    homepage = "https://github.com/hugsy/binja-headless";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
