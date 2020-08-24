{ stdenv
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, findutils
, gawk
, gnugrep
, nix
, vim
}:
let
  path = [
    bash
    coreutils
    findutils
    gawk
    gnugrep
    nix
    vim
  ];
in
stdenv.mkDerivation rec {
  name = "nixify";

  src = fetchFromGitHub {
    owner = "kampka";
    repo = "nixify";
    rev = "22b907e39499ad69b5145e7a4cea9fd03869e111";
    sha256 = "0dr6cxg0c4pjimdw40cb4f3bvr0iz7nn09n8yl7sb4810p6msdxc";
  };

  installPhase = ''
    DEST_DIR="$out" PREFIX="" make install
    wrapProgram $out/bin/nixify \
      --prefix PATH : ${ stdenv.lib.makeBinPath path }
  '';

  nativeBuildInputs = [ makeWrapper ];

  meta = with stdenv.lib; {
    description = "Bootstrap nix-shell environments";
    homepage = https://github.com/kampka/nixify;
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
