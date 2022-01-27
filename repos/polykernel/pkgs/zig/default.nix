{ lib
, cmake
, fetchFromGitHub
, libxml2
, llvmPackages
, zlib
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "zig";
  version = "master";

  src = fetchFromGitHub {
    owner = "ziglang";
    repo = pname;
    rev = "b463924da2b1ed4ae83a51c18b4998531c44d809";
    sha256 = "sha256-K2lkb+BFPyXhzDJseaZlVggtEdvuAcZnCrslyND3kvY=";
  };

  nativeBuildInputs = [
    cmake
    llvmPackages.llvm.dev
  ];

  buildInputs = [
    libxml2
    llvmPackages.libclang
    llvmPackages.lld
    llvmPackages.llvm
    zlib
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ./zig test --cache-dir "$TMPDIR" -I $src/test $src/test/behavior.zig
    runHook postCheck
  '';

  meta = with lib; {
    description = "A general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.";
    homepage = "https://github.com/ziglang/zig";
    license = licenses.mit;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.unix;
    # See https://github.com/NixOS/nixpkgs/issues/86299
    broken = llvmPackages.stdenv.hostPlatform.isDarwin;
  };
}
