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
  version = "1.0.0-beta.8";

  src = fetchFromGitHub {
    rev = "2b92d2447696058e1f8c9ef629be97eb03afe816";
    owner = "surrealdb";
    repo = pname;
    sha256 = "sha256-m7Kr+HlakdkCv2VxmK+KUUj76Xj7eN/eeE7Cg0tn1Ic=";
  };

  cargoSha256 = "sha256-vaAfOsbIdQXpx7v4onXY1J8ANKCccVRuWxdvX5+f2no=";
  buildInputs = [
    llvmPackages_latest.llvm
    llvmPackages_latest.bintools
    openssl
    rustup
  ];
  
  nativeBuildInputs = [ pkg-config ];

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
    #license = licenses.mit;
    #maintainers = [ maintainers.oluceps ];
  };
}
