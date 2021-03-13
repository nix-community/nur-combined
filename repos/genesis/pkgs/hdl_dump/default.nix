{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "unstable-2020-29-12";
  pname = "hdl_dump";

  src = fetchFromGitHub {
    owner = "ps2homebrew";
    repo = "hdl-dump";
    rev = "b7c85abe5a1c7b1aa8ad402499932c673c1cecd2";
    sha256 = "1ijg4nvq865qgp99dmc5np5snb5aibjmvflmj6mj82kszmbbakip";
  };

  installPhase = ''
    install -Dm755 hdl_dump -t $out/bin
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "PlayStation 2 HDLoader image dump/install utility";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ genesis ];
  };
}
