{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  llvmPackages,
  clang-cl,
  rustc,
  windows,
}:
stdenvNoCC.mkDerivation {
  inherit (rustc) version;
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
      --add-flag "-Clink-arg=/vctoolsdir:${windows.sdk}/crt" \
      --add-flag "-Clink-arg=/winsdkdir:${windows.sdk}/sdk"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    "$out/bin/rustc" ${./hello.rs} -o hello.exe

    echo "Checking..."
    if test -f hello.exe; then
      echo "found hello.exe!"
    else
      echo "hello.exe not found!"
      exit 1
    fi
  '';

  meta = rustc.meta // {
    description = "rustc wrapped for cross-compiling to MSVC from Unix systems";
    maintainers = [ lib.maintainers.RossSmyth ];
  };
}
