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
    rev = "a8e7ccd88fa128d9f6d8bdff77d093a488cb231a";
    sha256 = "07gcl39fddp20p1nisjrdryswbrn25kcj7hjmm8xkfmf017spyzm";
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
