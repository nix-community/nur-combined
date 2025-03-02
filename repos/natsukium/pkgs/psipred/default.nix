{
  lib,
  stdenv,
  fetchgit,
  blast,
  tcsh,
  dbPath ? "uniref90",
}:

stdenv.mkDerivation rec {
  pname = "psipred";
  version = "4.0";

  src = fetchgit {
    url = "https://github.com/psipred/psipred";
    tag = "v${version}";
    hash = "sha256-7mWHg7YTL+yRWZWbvkCTErxi9bUkGw4mMknC2bO9Pbs=";
  };

  buildInputs = [
    blast
    tcsh
  ];

  postPatch = ''
    substituteInPlace ./BLAST+/runpsipredplus \
      --replace-fail "uniref90filt" "${dbPath}" \
      --replace-fail "/usr/local/bin" "${blast}/bin" \
      --replace-fail "../bin" "$out/bin" \
      --replace-fail "../data" "$out/data"
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-int";

  preBuild = ''
    cd ./src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/data
    cp psipred psipass2 chkparse seq2mtx ../BLAST+/runpsipredplus $out/bin
    cp -r ../data $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Protein Secondary Structure Predictor";
    homepage = "http://bioinf.cs.ucl.ac.uk/psipred";
    license = licenses.boost;
    platforms = platforms.linux;
  };
}
