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
    rev = "8f3ab96b0e8cd22dc98f9fe352c5d4fff491dd0e";
    sha256 = "sha256-TMESKLjFZKvZPC/6is4OmL0wscrRVgdqRqxFBcBhQY8=";
  };

  nativeBuildInputs = [
    cmake
    llvmPackages.llvm.dev
  ];

  buildInputs = [
    libxml2
    llvmPackages.libclang
    llvmPackages.lld
    llvmPackages.bintools
    zlib
  ];

  cmakeFlags = [
    # lld cannot find the system zlib after the llvm14 toolchain upgrade
    # https://github.com/ziglang/zig/issues/12069
    # https://github.com/ziglang/zig/issues/12167
    "-DZIG_STATIC_ZLIB=ON"

    # workaround for `file RPATH_CHANGE could not write new RPATH` error
    # https://github.com/NixOS/nixpkgs/issues/22060
    # https://github.com/ziglang/zig/issues/12218
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
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
