{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dapnetgateway";
  version = "2024-01-29";

  src = fetchFromGitHub {
    owner = "g4klx";
    repo = "DAPNETGateway";
    rev = "41ba7fb13bdad3be08e77699078b1c09206be036";
    sha256 = "1AKlZ4sB8FY+DpkM8W+iWXxzeCOdTJvrvAM9xJ6rPD8=";
  };

  patches = [
    ./0001-Add-missing-cstdint-include.patch
  ];

  installPhase = ''
    install -Dm775 DAPNETGateway $out/bin/DAPNETGateway
  '';

  meta = {
    description = "Gateway to the DAPNET POCSAG network";
    homepage = "https://github.com/g4klx/DAPNETGateway";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2;
  };
})
