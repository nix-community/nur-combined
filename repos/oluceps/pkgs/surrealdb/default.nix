{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, llvmPackages_latest
, clang
, pkg-config
, openssl
, rustc
, cmake
, rustup
, glibc
, glib
}:

rustPlatform.buildRustPackage rec {
  pname = "surrealdb";
  version = "1.0.0-beta.7";

  src = fetchFromGitHub {
    rev = "a97ff7ac32f7f6eaf28f7b925319768462c1a8d8";
    owner = "oluceps";
    repo = pname;
    sha256 = "sha256-xYIp1k2jpdjamkOxc0WCrHwYGIdNBQl7e+g0vjJTyYM=";
  };
  
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildInputs = [
    llvmPackages_latest.llvm
    llvmPackages_latest.bintools
    openssl
    rustup
  ];

  LIBCLANG_PATH = lib.makeLibraryPath [ llvmPackages_latest.libclang.lib ];
  # Add libvmi precompiled library to rustc search path
  # Add libvmi, glibc, clang, glib headers to bindgen search path
  BINDGEN_EXTRA_CLANG_ARGS = # Includes with special directory paths
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      glibc.dev
    ]) ++
    [
      ''-I"${llvmPackages_latest.libclang.lib}/lib/clang/${llvmPackages_latest.libclang.version}/include"''
      ''-I"${glib.dev}/include/glib-2.8"''
      ''-I${glib.out}/lib/glib-2.8/include/''
    ];
  

  meta = with lib; {
    homepage = "https://github.com/surrealdb/surrealdb";
    description = "A scalable, distributed, collaborative, document-graph database, for the realtime web";
    license = licenses.mit;
    maintainers = [ maintainers.oluceps ];
  };
}
