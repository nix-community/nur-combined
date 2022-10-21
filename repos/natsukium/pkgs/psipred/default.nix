{ lib, stdenv, fetchgit, blast, tcsh, dbPath ? "uniref90"}:

stdenv.mkDerivation rec {
  pname = "psipred";
  version = "v4.0";

  src = fetchgit {
    url = "https://github.com/psipred/psipred";
    rev = version;
    sha256 = "1frxpnrxkhj968k0w6r4npsn5g0jjd0bx6wmb68yqbqkns1qfrgf";
  };

  buildInputs = [ blast tcsh ];

  prePatch = ''
    substituteInPlace ./BLAST+/runpsipredplus \
      --replace "uniref90filt" "${dbPath}" \
      --replace "/usr/local/bin" "${blast}/bin" \
      --replace "../bin" "$out/bin" \
      --replace "../data" "$out/data"
  '';

  # patches = [ ./runpsipredplus.patch ];

  preBuild = ''
    cd ./src
  '';

  installPhase = ''
    mkdir -p $out/bin $out/data
    cp psipred psipass2 chkparse seq2mtx ../BLAST+/runpsipredplus $out/bin
    cp -r ../data $out/
  '';


  meta = with lib;
  {
    description = "Protein Secondary Structure Predictor";
    homepage = "http://bioinf.cs.ucl.ac.uk/psipred";
    license = licenses.boost;
    platforms = platforms.linux;
  };
}
