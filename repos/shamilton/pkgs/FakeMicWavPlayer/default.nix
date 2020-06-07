{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pulseaudio
, pkg-config
}:
stdenv.mkDerivation rec {

  pname = "FakeMicWavPlayer";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeMicWavPlayer";
    rev = "master";
    sha256 = "176qhl0lmajf5a8w6rjsklrvab49mm74p38fga63n03999bmnx4h";
  };

  nativeBuildInputs = [ pkg-config ninja meson ];

  buildInputs = [ pulseaudio ];

  postPatch = ''
    substituteInPlace pkg-config/fake.pc \
      --replace @FakeLibPrefix@ $out
  '';

  meta = with lib; {
    description = "A cool desktop panel for KDE Plasma 5";
    license = licenses.mit;
    homepage = "https://dangvd.github.io/ksmoothdock/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
