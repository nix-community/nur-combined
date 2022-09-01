{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aml-upgrade-package-extract";
  version = "2019-09-24";
  src = fetchFromGitHub {
    owner = "Portisch";
    repo = "aml-upgrade-package-extract";
    rev = "159f172df587a93a814f45a9e9ebea260d50a558";
    sha256 = "sha256-Lg/R1ckQm/k3ezky1FubW9c3eAtRhgRZcDrl3015/TI=";
  };
  installPhase = ''
    install -Dm755 aml-upgrade-package-extract $out/bin/aml-upgrade-package-extract
  '';
  meta = with lib; {
    description = "Amlogic Burn Card Maker alternative for Linux";
    license = licenses.free;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
