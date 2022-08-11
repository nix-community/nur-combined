{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sddm-lain-wired-theme";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "lll2yu";
    repo = pname;
    rev = version;
    sha256 = "sha256-kvis9d9AfQk8tAzQeKTURl56Sqs3dttqPV3wNLvGEiw=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/${pname}
    cp * $out/share/sddm/themes/${pname}
  '';

  meta = with lib; {
    description = "A sddm theme inspired by Serial experiments lain";
    homepage = "https://github.com/lll2yu/sddm-lain-wired-theme";
    license = licenses.cc-by-sa-40;
    platforms = platforms.linux;
  };
}
