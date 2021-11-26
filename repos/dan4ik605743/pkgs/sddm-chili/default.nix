{ lib, stdenv, fetchFromGitHub, }:

stdenv.mkDerivation rec {
  name = "sddm-chili";

  src = fetchFromGitHub {
    owner = "MarianArlt";
    repo = name;
    rev = "6516d50176c3b34df29003726ef9708813d06271";
    sha256 = "sha256-wxWsdRGC59YzDcSopDRzxg8TfjjmA3LHrdWjepTuzgw=";
  };

  installPhase = ''
    mkdir $out/share/sddm/themes/${name} -p
    cp ${src}/* $out/share/sddm/themes/${name}/. -aR
  '';

  meta = with lib; {
    description = "Theme for SDDM";
    homepage = "https://github.com/MarianArlt/sddm-chili";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
