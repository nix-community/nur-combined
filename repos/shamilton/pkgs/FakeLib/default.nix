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
    rev = "76f36bd48414ad87d2f17a60bd4c15596a5c2bf9";
    sha256 = "1a334w4hifk3b38904w9zyh52axbjj8w90zfn01fz4wnvzg7dkmx";
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
