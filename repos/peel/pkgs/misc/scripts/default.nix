{ pkgs, stdenv }:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "1.0.1";
  baseName = "peel-scripts";
  name = "${baseName}-${version}";

  buildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${./bin}/* $out/bin/
    for f in `find $out/bin -type f -maxdepth 1`; do
      chmod a+x $f
      wrapProgram $f --prefix PATH : "${wrapperPath}"
    done
  '';

  wrapperPath = with stdenv.lib; makeBinPath (with pkgs;
       [ coreutils ]
    ++ [ ripgrep ]
    ++ optionals stdenv.isLinux [ feh ]
    ++ [ curl fzf fasd ]);

  meta = with stdenv.lib; {
    description = "Some useful scripts I often use";
    platforms = platforms.unix;
    license = licenses.gpl3;
  };
}
