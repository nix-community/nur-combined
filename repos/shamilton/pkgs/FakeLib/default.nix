{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pulseaudio
, pkg-config
, enableDebugging
, breakpointHook
}:
stdenv.mkDerivation rec {

  pname = "libfake";
  version = "unstable";
  debug = false;

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeLib";
    rev = "master";
    sha256 = "192jszlkhg96ik36mp117mgyb6ack1ilbxidx0y0fyxn12qjx7rk";
  };

  mesonFlags = [ 
    (if debug then "--buildtype=debug" else "--buildtype=plain" ) 
    "-Dcpp_args=-Wall"
    "-Dwerror=true"
  ];

  dontStrip = if debug then true else false;

  nativeBuildInputs = [ breakpointHook pkg-config ninja meson ];

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
