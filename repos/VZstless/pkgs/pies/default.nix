{
  lib,
  stdenv,
  fetchurl,
  libxcrypt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pies";
  version = "1.9";
  src = fetchurl {
    url = "https://download.gnu.org.ua/pub/release/pies/pies-${finalAttrs.version}.tar.gz";
    sha256 = "QlrWyWHrd813fJmEbyP7z2A+epqS2eAC6OQzLYLePeo=";
  };

  buildInputs = [ libxcrypt ];

  meta = {
    description = "Program Invocation and Execution Supervisor";
    homepage = "https://www.gnu.org.ua/software/pies/pies.html";
    license = lib.licenses.gpl3;
    mainProgram = "pies";
  };
})
