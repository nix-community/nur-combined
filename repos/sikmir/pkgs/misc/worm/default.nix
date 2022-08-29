{ lib, stdenv, nimPackages, fetchFromGitHub, pkg-config, xorg }:

nimPackages.buildNimPackage rec {
  pname = "worm";
  version = "0.3.1";
  nimBinOnly = true;

  src = fetchFromGitHub {
    owner = "codic12";
    repo = "worm";
    rev = "v${version}";
    hash = "sha256-I+dRcsVaZWsZZch+17Y5Ypl8j7qGNHPFijPXV5NbqKA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = with nimPackages; [
    pixie
    regex
    unicodedb
    (fetchNimble {
      pname = "x11";
      version = "1.1";
      hash = "sha256-2XRyXiBxAc9Zx/w0zRBHRZ240qww0FJvIvOKZ8YH50A=";
    })
  ] ++ (with xorg; [ libX11 libXft libXinerama ]);

  postInstall = ''
    install -Dm644 assets/worm.desktop -t $out/share/applications
  '';

  meta = with lib; {
    description = "A dynamic, tag-based window manager written in Nim";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
