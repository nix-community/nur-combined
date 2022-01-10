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
    rev = "7355a201336c8e3892427e5932fe5cdd46cf96df";
    sha256 = "sha256-w5CFmE2GGS+foYcrhd7WIMHK8a44NawBVKCnp9qWI6Q=";
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
