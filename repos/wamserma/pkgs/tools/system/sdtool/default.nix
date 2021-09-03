{ lib
, stdenv
, fetchFromGitHub
, dietlibc ? null
, static ? dietlibc != null
}:

let
  pname = if static then "sdtool-static" else "sdtool";
  version = "git-6154df2";
  commit = "6154df2cd4ef40554ada801eb0bf6547ba4ee2ea";
  sha256 = "0pyh4kqs3hi3yg1inbp6jdqsq6hbdjv3c0y8p6zyq64hb1p15jz2";
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

  patchPhase = ''
    sed -i '103s/strncpy(devname,filename+i,sizeof(devname));/strncpy(devname,filename+i,sizeof(devname)-1);/' src/sdcmd.c
  '';

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
