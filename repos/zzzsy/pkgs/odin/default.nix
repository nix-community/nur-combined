{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "odin";
  version = "4";

  src = fetchurl {
    url = "https://assets.zzzsy.top/${pname}${version}.tar.gz";
    hash = "sha256-xTIrn5uXIniS9XO2C/QJUyxAlCvZxwolyTkhRHofWSg=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D odin4 $out/bin/odin
  '';
}
