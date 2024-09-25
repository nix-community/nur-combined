{
  stdenvNoCC,
  lib,
  fetchurl,
  p7zip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "hesuvi-hrir";
  version = "2.0.0.1";
  src = fetchurl {
    url = "https://sourceforge.net/projects/hesuvi/files/HeSuVi_${version}.exe/download";
    sha256 = "1fh1lqkv992xjglwkp3b544ai552pyjbmgfm9yp8fylg9mqp85x3";
  };

  nativeBuildInputs = [ p7zip ];
  unpackCmd = "7z x $src";

  installPhase = ''
    runHook preInstall

    cp -r hrir $out

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Headphone Surround Virtualizations for Equalizer APO";
    homepage = "https://sourceforge.net/projects/hesuvi/";
    license = licenses.free;
  };
}
