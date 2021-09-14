{ lib
, stdenv
, fetchFromGitHub
, dietlibc ? null
, static ? dietlibc != null
}:

let
  pname = if static then "sdtool-static" else "sdtool";
  version = "git-" + lib.strings.substring 0 6 commit;
  commit = "ad4155c1d2988a17f4d5b13feaa6e4c1beb2cf4b";
  sha256 = "17nyc1zng5j2zzq5jfg42ckgnhqiv0pb8vidgvvbh3zxdccnaj1q";
in
# "Only static builds supported with dietlibc."
assert dietlibc != null -> static; stdenv.mkDerivation {
  inherit pname;
  inherit version;
  inherit commit;

  src = fetchFromGitHub {
    owner = "BertoldVdb";
    repo = "sdtool";
    rev = commit;
    inherit sha256;
  };

  buildInputs = [ dietlibc ];

  preBuild = lib.optionalString (dietlibc != null) ''
    export CC="diet gcc"
  '';

  enableParallelBuilding=true;

  installPhase = ''
    mkdir -p $out/bin
    cp sdtool $out/bin/sdtool
  '';

  doCheck = false;

  meta = with lib; {
    homepage = "https://bertold.org/";
    description = "a tool to read and modify the write lock flags on SD cards";
    license = [ licenses.bsd3 ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux;
  };
}
