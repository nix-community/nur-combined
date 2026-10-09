{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-developer-utilities";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "xxyangyoulin";
    repo = "dms-plugin-developer-utilities";
    rev = "120512d8c54350c267aa5264cb3c09c3cf26ad30";
    hash = "sha256-sSjYCAjXyp6Iw3QHuPJ4vsXCijAmFYpsT4AafHS2Ifo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin with encoders, decoders, formatters, and converters for developers";
    homepage = "https://github.com/xxyangyoulin/dms-plugin-developer-utilities";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
