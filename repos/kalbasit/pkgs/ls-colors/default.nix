{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  name = "lscolors-unstable-${version}";
  version = "2019-02-01";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "ea316590b3f6c9784c21445bd575e16fc4b1ff2f";
    sha256 = "1bj3q6s7yfglj7bpc8hjw05bz1byhm95ml2iyzr72vda4jn6ll7m";
  };

  buildPhase = ''
    dircolors -b $src/LS_COLORS > bourne-shell.sh
    dircolors -c $src/LS_COLORS > c-shell.sh
  '';

  installPhase = ''
    mkdir -p $out/ls-colors
    mv bourne-shell.sh c-shell.sh $out/ls-colors/
  '';

  meta = with stdenvNoCC.lib; {
    description = "A collection of LS_COLORS definitions; needs your contribution!";
    longDescription = ''
      This is a collection of extension:color mappings, suitable to use as your
      LS_COLORS environment variable. Most of them use the extended color map,
      described in the ECMA-48 document; in other words, you'll need a terminal
      with capabilities of displaying 256 colors.
    '';
    homepage = https://github.com/trapd00r/LS_COLORS;
    license = licenses.artistic1;
    platforms = platforms.all;
    maintainers = with maintainers; [ kalbasit ];
  };
}
