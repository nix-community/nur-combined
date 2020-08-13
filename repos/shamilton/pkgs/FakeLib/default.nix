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

  # src = fetchFromGitHub {
  #   owner = "SCOTT-HAMILTON";
  #   repo = "FakeLib";
  #   rev = "b4c0d3528325890e614cba90a6c2c12e304b5e71";
  #   sha256 = "01659s1dky0gmjg0rbi8p0k1v9l774mqrlf89rx8m6czbdd5virb";
  # };

  src = ./src.tar.gz;

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
