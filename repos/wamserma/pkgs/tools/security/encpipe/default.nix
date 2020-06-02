{ lib
, stdenv
, fetchFromGitHub
, dietlibc ? null
, static ? dietlibc != null
}:

let
  pname = if static then "encpipe-static" else "encpipe";
  version = "0.5";
  sha256 = "1mk178kf7vbk92hshylfm20giy8dgncc16s9if1hrffrdi4hllb2";
in
# "Only static builds supported with dietlibc."
assert dietlibc != null -> static; stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "jedisct1";
    repo = "encpipe";
    rev = version;
    fetchSubmodules = true;
    inherit sha256;
  };

  buildInputs = [ dietlibc ];

  preBuild = lib.optionalString (dietlibc != null) ''
    export CC="diet gcc"
  '';

  enableParallelBuilding=true;

  installPhase = ''
    make PREFIX=$out install
  '';

  checkPhase = ''
    make test
    # test with static data
    echo encpipe is good to go | ./encpipe -e -p password | ./encpipe -d -p password  | { read testres; test "$testres" = "encpipe is good to go"; }
    # test with random data
    export PASS=$(dd if=/dev/urandom bs=1 count=16 | base64)
    dd status=none if=/dev/urandom bs=1 count=64K | tee >(./encpipe -e -p $PASS | ./encpipe -d -p $PASS | base64 -w 0) >(base64 -w 0 | awk '{print $0}' ) > /dev/null | awk '{if(NR>1){if(_n==$1) print "OK"};_n=$1}' | { read testres; test "$testres" = "OK"; }
  '';

  doCheck = true;

  meta = with lib; {
    homepage = "https://github.com/jedisct1/encpipe";
    description = "a simple, pipeable encryption tool without runtime deps";
    license = [ licenses.gpl2 ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux;
  };
}
