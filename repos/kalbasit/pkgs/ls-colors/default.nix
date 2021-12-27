{ stdenvNoCC, fetchFromGitHub, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "lscolors-unstable";
  version = "2021-07-27";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "2957904dbd4156b7980e3450233f811073132023";
    sha256 = "sha256-46UR3lKOAoMdcIolVzyqMyGs+Q2DXeq7xUubTLxS3/I=";
  };

  buildPhase = ''
    dircolors -b $src/LS_COLORS > bourne-shell.sh
    dircolors -c $src/LS_COLORS > c-shell.sh
  '';

  installPhase = ''
    mkdir -p $out/ls-colors
    mv bourne-shell.sh c-shell.sh $out/ls-colors/
  '';

  meta = {
    description = "A collection of LS_COLORS definitions; needs your contribution!";
    longDescription = ''
      This is a collection of extension:color mappings, suitable to use as your
      LS_COLORS environment variable. Most of them use the extended color map,
      described in the ECMA-48 document; in other words, you'll need a terminal
      with capabilities of displaying 256 colors.
    '';
    homepage = https://github.com/trapd00r/LS_COLORS;
    license = lib.licenses.artistic1;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.kalbasit ];
  };
}
