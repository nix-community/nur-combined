{ stdenv, system, fetchzip, lib }:

let
  targets = {
    x86_64-linux = "x64-linux";
    x86_64-darwin = "x64-macos";
  };
in
stdenv.mkDerivation rec {
  pname = "wd";
  version = "1.1.0";
  src = fetchzip {
    url = "https://github.com/kakkun61/wd/releases/download/1.1.0/wd-${version}-${targets.${system}}.zip";
    sha256 = "sha256-b/DmrIzoTurSOK3Z6DzlSIJfEcRxKoHEbL/IbaUR9Gs=";
  };
  installPhase = "install -Dm755 wd $out";
  meta = with lib; {
    homepage = https://github.com/kakkun61/wd;
    changelog = "https://github.com/kakkun61/wd/releases/tag/${version}";
    license = licenses.gpl3;
    maintainers = [ maintainers.kakkun61 ];
    platforms = platforms.all;
    broken = true;
  };
}
