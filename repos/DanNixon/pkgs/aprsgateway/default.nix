{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aprsgateway";
  version = "2024-01-29";

  src = fetchFromGitHub {
    owner = "g4klx";
    repo = "APRSGateway";
    rev = "7fd8ad32b5b628e3f7532ba52771fc3bbb7ae8b4";
    sha256 = "+WvGAPuTlqb8Ie/7LGErpfC4EW+OEjifG7C1FOIh7CY=";
  };

  installPhase = ''
    install -Dm775 APRSGateway $out/bin/APRSGateway
  '';

  meta = {
    description = "A single point of access to the APRS network for the other gateway programs";
    homepage = "https://github.com/g4klx/APRSGateway";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2;
  };
})
