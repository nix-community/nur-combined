{
  lib,
  autoPatchelfHook,
  fetchurl,
  glibc,
  libffi,
  makeWrapper,
  ncurses,
  openssl,
  python311,
  stdenv,
  zlib,
}:

let
  pname = "cangjie";
  version = "1.1.0";
  sdkName = "cangjie-sdk-linux-x64-${version}.tar.gz";

  runtimeDeps = [
    libffi
    ncurses
    openssl
    python311
    stdenv.cc.cc.lib
    zlib
  ];

  toolDeps = [
    stdenv.cc
    stdenv.cc.bintools
  ];

  gccLibDir = "${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${stdenv.cc.cc.version}";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=${sdkName}&objectKey=69e9d50c21f5a8178d6fd219";
    name = sdkName;
    hash = "sha256-XOfoyFI6rZz1ll+Bgknho58QeIljrvfFhSaXo6yWQGA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeDeps;

  installPhase = ''
    runHook preInstall

    sdk="$out/share/cangjie"
    toolchain="$out/libexec/cangjie-toolchain"
    mkdir -p "$sdk" "$out/bin" "$toolchain/bin"
    cp -r . "$sdk"
    chmod -R u+w "$sdk"

    cat > "$toolchain/bin/ld" <<'EOF'
    #!${stdenv.shell}
    set -eu

    args=()
    replace_dynamic_linker=0
    for arg in "$@"; do
      if [ "$replace_dynamic_linker" = 1 ]; then
        args+=("${glibc}/lib/ld-linux-x86-64.so.2")
        replace_dynamic_linker=0
        continue
      fi

      case "$arg" in
        -dynamic-linker)
          args+=("$arg")
          replace_dynamic_linker=1
          ;;
        Scrt1.o) args+=("${stdenv.cc.libc}/lib/Scrt1.o") ;;
        crti.o) args+=("${stdenv.cc.libc}/lib/crti.o") ;;
        crtn.o) args+=("${stdenv.cc.libc}/lib/crtn.o") ;;
        crtbeginS.o) args+=("${gccLibDir}/crtbeginS.o") ;;
        crtendS.o) args+=("${gccLibDir}/crtendS.o") ;;
        *) args+=("$arg") ;;
      esac
    done

    exec ${stdenv.cc}/bin/ld "''${args[@]}"
    EOF
    chmod +x "$toolchain/bin/ld"

    sdkLibraryPath="$sdk/lib:$sdk/lib/linux_x86_64_cjnative:$sdk/modules/linux_x86_64_cjnative/std:$sdk/runtime/lib/linux_x86_64_cjnative:$sdk/third_party/llvm/lib:$sdk/tools/lib"
    runtimeLibraryPath="${lib.makeLibraryPath runtimeDeps}:$sdkLibraryPath"
    sdkPath="$toolchain/bin:$sdk/bin:$sdk/tools/bin:$sdk/third_party/llvm/bin:${lib.makeBinPath toolDeps}"

    for tool in "$sdk"/bin/* "$sdk"/tools/bin/*; do
      if [ -f "$tool" ] && [ -x "$tool" ]; then
        toolName="$(basename "$tool")"
        wrapperArgs=(
          --set CANGJIE_HOME "$sdk"
          --prefix PATH : "$sdkPath"
          --prefix LD_LIBRARY_PATH : "$runtimeLibraryPath"
        )

        if [ "$toolName" = cjc ]; then
          wrapperArgs+=(--add-flags --set-runtime-rpath)
        fi

        makeWrapper "$tool" "$out/bin/$toolName" "''${wrapperArgs[@]}"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Cangjie programming language SDK";
    homepage = "https://cangjie-lang.cn/";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
