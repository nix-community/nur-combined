{
  lib,
  stdenvNoCC,
  makeWrapper,
  llvmPackages,
  fetchMsvcSdk,
  msvcSdk,
}:
stdenvNoCC.mkDerivation {
  pname = "clang-cl-wrapped";
  inherit (llvmPackages.clang-unwrapped) version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    llvmPackages.clang-unwrapped
    llvmPackages.bintools-unwrapped
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper ${lib.getExe' llvmPackages.clang-unwrapped "clang-cl"} "$out/bin/clang-cl" \
      --run 'BIN="${msvcSdk}/bin/x64" . ${fetchMsvcSdk}/msvcenv-native.sh'

    makeWrapper ${lib.getExe' llvmPackages.bintools-unwrapped "lld-link"} "$out/bin/lld-link" \
      --run 'BIN="${msvcSdk}/bin/x64" . ${fetchMsvcSdk}/msvcenv-native.sh'
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    "$out/bin/clang-cl" -Fo"$TMPDIR/" -c ${./hello.c}

    echo "linking..."
    "$out/bin/lld-link" "$TMPDIR"/*.obj -out:hello.exe

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
}
