{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  llvmPackages,
  msvcSdk,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "clang-cl-wrapped";
  inherit (llvmPackages.clang-unwrapped) version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper ${lib.getExe' llvmPackages.clang-unwrapped "clang"} "$out/bin/clang-cl" \
      --inherit-argv0 \
      --append-flags "--target=x86_64-pc-windows-msvc" \
      --append-flags "-fuse-ld=lld-link" \
      --append-flags "/winsysroot ${msvcSdk}" \
      --prefix PATH : ${lib.makeBinPath [ llvmPackages.bintools-unwrapped ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    "$out/bin/clang-cl" ${./hello.c} -o hello.exe

    echo "checking..."
    if [ ! -f hello.exe ]; then
      echo "hello.exe not found!"
      exit 1
    else
      echo "found hello.exe!"
    fi
  '';

  meta = llvmPackages.clang-unwrapped.meta // {
    mainProgram = "clang-cl";
  };
})
