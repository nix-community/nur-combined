{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pulseaudio
, pkg-config
, enableDebugging
}:
stdenv.mkDerivation rec {

  pname = "libfake";
  version = "unstable";
  debug = false;

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeLib";
    rev = "master";
    sha256 = "1mv68kr7ry8jzjjm8bfj5g677m5nlq5mn62l723a4vij4vy7qhg0";
  };

  mesonFlags = [ (if debug then "--buildtype=debug" else "--buildtype=plain" ) ];

  dontStrip = if debug then true else false;

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
