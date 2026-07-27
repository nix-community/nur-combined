{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  llvmPackages,
  windows,
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
      --add-flag "/vctoolsdir ${windows.sdk}/crt" \
      --add-flag "/winsdkdir ${windows.sdk}/sdk" \
      --prefix PATH : ${lib.makeBinPath [ llvmPackages.bintools-unwrapped ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    "$out/bin/clang-cl" ${./hello.c} -o hello.exe

    echo "checking..."
    if test -f hello.exe; then
      echo "found hello.exe!"
    else
      echo "hello.exe not found!"
      exit 1
    fi
  '';

  meta = llvmPackages.clang-unwrapped.meta // {
    mainProgram = "clang-cl";
  };
})
