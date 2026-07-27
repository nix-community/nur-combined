{ lib, stdenv, perlPackages, fetchFromGitHub, BioPerl, hmmer, infernal, blast ? null, ncbi_tools, aragorn, gnugrep, findutils, parallel, jdk, prodigal, makeWrapper, BioSearchIOhmmer }:
let perl = perlPackages.perl.withPackages (pkgs: with pkgs; [ 
      XMLSimple BioPerl BioSearchIOhmmer
      ]);
    toolsPath = lib.makeBinPath [ hmmer infernal blast ncbi_tools aragorn gnugrep findutils parallel prodigal jdk ];
in stdenv.mkDerivation rec {
  version = "1.4.15";
  name = "prokka-${version}";

  src = fetchFromGitHub {
    owner = "tseemann";
    repo = "prokka";
    rev = "4d6894d61e290de669aaa730765f0108c4e2486a";
    sha256 = "sha256:1bd9iqc5ikyzd407g26cznvq8mv6xjhrka29qyhwh4nk7zf3zjrx";
  };

  buildInputs = [ perl makeWrapper ];

  outputs = [ "out" "db" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin/prokka* $out/bin/
    wrapProgram $out/bin/prokka --prefix PATH : "${toolsPath}"
    mkdir -p $db/share/prokka
    cp -r db $db/share/prokka/
  '';

  meta = {
    platforms = lib.platforms.linux;
    broken = blast == null;
  };
}
