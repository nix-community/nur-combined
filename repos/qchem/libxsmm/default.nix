{ stdenv, fetchFromGitHub, which
, gfortran, python, blas, utillinux
, optAVX ? false
} :

let
  version = "1.15";

in stdenv.mkDerivation rec {
  pname = "libxsmm";
  inherit version;

  src = fetchFromGitHub {
    owner = "hfp";
    repo = "libxsmm";
    rev = version;
    sha256 = "1406qk7k2k4qfqy4psqk55iihsrx91w8kjgsa82jxj50nl9nw5nj";
  };

  nativeBuildInputs = [ which python utillinux ];
  buildInputs = [ gfortran ];

  postPatch = ''
    for i in ./scripts ./tests .mktmp.sh ./.state.sh; do
      patchShebangs $i
    done
  '';

  makeFlags = [
    "STATIC=0"
    "FC=gfortran"
    "OMP=1"
  ] ++ stdenv.lib.optional (!optAVX) "AVX=2";

  preInstall = ''
    mkdir -p $out
    installFlagsArray+=("PREFIX=$out")
  '';

  enableParallelBuilding = true;

  checkInputs = [ blas ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Library for specialized dense and sparse matrix operations targeting Intel Architecture";
    homepage = https://github.com/hfp/libxsmm;
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ] ;
  };
}

