{ stdenv, fetchFromGitHub, perlPackages, makeWrapper, blast ? null, ncbi_tools, any2fasta, unzip, gzip }:
let perl = perlPackages.perl.withPackages (pkgs: with pkgs; [
      PathTiny ListMoreUtils
    ]);
    external = [ blast ncbi_tools any2fasta unzip gzip ];
in stdenv.mkDerivation rec {
  version = "0.9.8";
  name = "abricate-${version}";

  src = fetchFromGitHub {
    owner = "tseemann";
    repo = "abricate";
    rev = "v${version}";
    sha256 = "sha256:0sg3n7jdrz0gr46qflfxs2f0q2hwkfwy69s7i2b129rxhvar48sq";
  };

  buildInputs = [ perl makeWrapper ] ++ external;

  postPatch = ''
    patchShebangs bin/abricate
  '';

  doCheck = true;

  checkPhase = ''
    bin/abricate --check
  '';

  installPhase = ''
    install -d $out/bin
    install -t $out/bin bin/*
  '';

  postFixup = ''
    wrapProgram $out/bin/abricate --prefix PATH : ${stdenv.lib.makeBinPath external}
  '';
  
  meta = with stdenv.lib; {
    platforms = platforms.linux;
    broken = isNull blast;
  };
}
