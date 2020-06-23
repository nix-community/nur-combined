{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pulseaudio
, pkg-config
}:
stdenv.mkDerivation rec {

  pname = "libfake";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeLib";
    rev = "master";
    sha256 = "0qb1mg430524bs4d1h6s34amlaimvizdgkilg15rzvsjbba13kcf";
  };

  nativeBuildInputs = [ pkg-config ninja meson ];

  buildInputs = [ pulseaudio ];

  postPatch = ''
    substituteInPlace pkg-config/fake.pc \
      --replace @FakeLibPrefix@ $out
  '';

  meta = with lib; {
    description = "An easy wrapper library around pulseaudio, written in c++";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/FakeLib";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
