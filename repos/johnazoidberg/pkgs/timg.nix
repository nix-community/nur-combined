{ stdenv, lib, fetchFromGitHub, libwebp, graphicsmagick }:
stdenv.mkDerivation rec {
  name = "timg-${version}";
  version = "0.9.5";

  sourceRoot = "source/src";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = "timg";

    rev = "v${version}";
    sha256 = "131b5wfgq83acvpqqzzg13fd5gdn0rrz3163my0rpbbnjsqvw21w";
  };

  buildInputs = [ libwebp graphicsmagick ];

  preInstall = ''
    export PREFIX=$out
    mkdir -p $out/bin
  '';

  meta = with lib; {
    description = "A viewer that uses 24-Bit color capabilities and unicode character blocks to display images in the terminal.";
    license = licenses.gpl2;
    homepage = https://github.com/hzeller/timg;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
