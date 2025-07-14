{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  llvmPackages,
  clang-cl,
  rustc,
  msvcSdk,
}:
stdenvNoCC.mkDerivation {
  inherit (rustc) version meta;
  pname = "rustc-wrapped";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper ${lib.getExe' rustc "rustc"} "$out/bin/rustc" \
      --prefix PATH : ${
        lib.makeBinPath [
          llvmPackages.bintools-unwrapped
          clang-cl
        ]
      } \
      --set CC ${lib.getExe clang-cl} \
      --add-flag "--target=x86_64-pc-windows-msvc" \
      --add-flag "-Clinker=lld-link" \
      --add-flag "-Clink-arg=/winsysroot:${msvcSdk}"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    "$out/bin/rustc" ${./hello.rs} -o hello.exe

    echo "Checking..."
    if [ ! -f hello.exe ]; then
      echo "hello.exe not found!"
      exit 1
    else
      echo "found hello.exe!"
    fi
  '';
}
