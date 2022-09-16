{ lib, stdenv, fetchfromgh, unzip }:

stdenv.mkDerivation rec {
  pname = "Amethyst-bin";
  version = "0.16.0";

  src = fetchfromgh {
    owner = "ianyh";
    repo = "Amethyst";
    version = "v${version}";
    name = "Amethyst.zip";
    hash = "sha256-pghX74T0JsAWkxAaAaQ5NIhYqj89fo0ZqRtxPThJZ/M=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Automatic tiling window manager for macOS à la xmonad";
    homepage = "https://ianyh.com/amethyst/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
