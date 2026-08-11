{ lib
, llvmPackages
, fetchFromGitHub
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "cmix";
  version = "19.1";

  src = fetchFromGitHub {
    owner = "byronknoll";
    repo = "cmix";
    # fix: src/models/ppmd.cpp:1314:7: error: use of undeclared identifier 'printf'
    /*
    rev = "v${version}";
    hash = "sha256-j6gYonAVuG2Z69Rl77Pn1ei7ApA7ExT4X2txbp96+Is=";
    */
    rev = "7d03c6c9981e52f04ec9c57fd8e172859d41e722";
    hash = "sha256-NI6nzYSlUpeZT8El4u7gw7zS3ZwUeQBMx+0BPI/Bd7A=";
  };

  #  # benchmark helper
  #  mkdir -p $out/share/doc/cmix
  #  cp enwik9-preproc $out/share/doc/cmix
  installPhase = ''
    mkdir -p $out/bin
    cp cmix $out/bin
  '';

  meta = with lib; {
    description = "file compressor";
    homepage = "https://github.com/byronknoll/cmix";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
