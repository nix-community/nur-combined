{ config
, stdenv
, lib
, fetchFromGitHub
, cmake
, cudaSupport ? config.cudaSupport or false
, cudatoolkit
, ncclSupport ? false
, nccl
, llvmPackages
}:

assert ncclSupport -> cudaSupport;

stdenv.mkDerivation rec {
  pname = "xgboost";
  version = "0.90";

  src = fetchFromGitHub {
    owner = "dmlc";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "1zs15k9crkiq7bnr4gqq53mkn3w8z9dq4nwlavmfcr5xr5gw2pw4";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake ] ++ lib.optional stdenv.isDarwin llvmPackages.openmp;

  buildInputs = lib.optional cudaSupport cudatoolkit
    ++ lib.optional ncclSupport nccl;

  cmakeFlags = lib.optionals cudaSupport [ "-DUSE_CUDA=ON" "-DCUDA_HOST_COMPILER=${cudatoolkit.cc}/bin/cc" ]
    ++ lib.optional ncclSupport "-DUSE_NCCL=ON";

  # We need the dmlc-core and rabit include files to compile
  # MCFOST. Some of these include headers with relative include path
  # into the source directory (see
  # https://github.com/dmlc/xgboost/issues/4893), so we need to create
  # a source directory in $out. Also include libdmlc.a and
  # librabbit.a, that seems to be needed as well.
  installPhase =
    let
      libname = "libxgboost${stdenv.hostPlatform.extensions.sharedLibrary}";
    in
    ''
      mkdir -p $out
      cp -r ../dmlc-core/include $out
      cp -r ../rabit/include $out
      cp -r ../include $out
      install -d $out/src/common
      cp ../src/common/*.h $out/src/common
      install -Dm755 ../lib/${libname} $out/lib/${libname}
      install -Dm755 ../xgboost $out/bin/xgboost
      cp -r ./dmlc-core/libdmlc.a $out/lib
      cp -r ./librabit.a $out/lib
    '';

  postFixup = lib.optionalString stdenv.isDarwin ''
    install_name_tool -id $out/lib/libxgboost.dylib $out/lib/libxgboost.dylib
  '';

  meta = with lib; {
    description = "Scalable, Portable and Distributed Gradient Boosting (GBDT, GBRT or GBM) Library";
    homepage = "https://github.com/dmlc/xgboost";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ abbradar ];
  };
}
