{ lib, stdenv, fetchgit, nix-update-script }:

stdenv.mkDerivation rec {
  pname = "core-math";
  version = "unstable-2026-06-25";

  src = fetchgit {
    url = "https://gitlab.inria.fr/core-math/core-math.git";
    rev = "d75331567ed75cca2cdd1b5b83cb74d07a985532";
    hash = "sha256-zS+mz6yGD5aciadHZ0HqucWND+IXaNPsYkKnFc0Urmc=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p build

    objs=""
    for type in binary32 binary64; do
      suffix=""
      [ "$type" = "binary32" ] && suffix="f"
      for dir in src/$type/*/; do
        fn=$(basename "$dir")
        srcfile="$dir/''${fn}''${suffix}.c"
        [ -f "$srcfile" ] || continue
        obj="build/''${type}_''${fn}.o"
        $CC $CFLAGS -O3 -fPIC -c -o "$obj" "$srcfile"
        objs="$objs $obj"
      done
    done

    ar rcs build/libcore-math.a $objs
    $CC -shared -o build/libcore-math.so $objs -lm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,include,src}

    cp build/libcore-math.a build/libcore-math.so $out/lib/
    cp -r src/{binary16,binaryb16,binary32,binary64,binary80,binary128,generic} $out/src/

    {
      echo "#pragma once"
      echo ""
      echo "#ifdef __cplusplus"
      echo "extern \"C\" {"
      echo "#endif"
      echo ""
      suffix=""
      for type in binary32 binary64; do
        [ "$type" = "binary32" ] && suffix="f" || suffix=""
        for dir in src/$type/*/; do
          fn=$(basename "$dir")
          srcfile="$dir/''${fn}''${suffix}.c"
          [ -f "$srcfile" ] || continue
          awk '
            /^(double|float|void)[[:space:]]*$/ { type=$0; next }
            /^cr_/ && type { sub(/[[:space:]]*\{[[:space:]]*$/, ""); print type " " $0 ";"; type=""; exit }
            /^(double|float|void) cr_/ { sub(/[[:space:]]*\{[[:space:]]*$/, ""); print $0 ";"; exit }
            { type="" }
          ' "$srcfile" || true
        done
      done
      echo ""
      echo "#ifdef __cplusplus"
      echo "}"
      echo "#endif"
    } > $out/include/core-math.h

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "High-performance mathematical functions with correct rounding";
    homepage = "https://core-math.gitlabpages.inria.fr/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
