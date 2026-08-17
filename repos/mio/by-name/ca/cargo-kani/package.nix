{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  zlib,
  gcc,
  stdenvAdapters,
}:

stdenv.mkDerivation rec {
  pname = "cargo-kani";
  version = "0.67.0";

  src = fetchzip {
    url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-I+GKPEWYXPZimCN79IB9dKiY8+NhP4Y8JjAS7R00XMs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    gcc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bin/* $out/bin/

    # If there are lib/ or other directories, we copy them too
    if [ -d lib ]; then
      mkdir -p $out/lib
      cp -r lib/* $out/lib/
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Kani Rust Verifier";
    homepage = "https://model-checking.github.io/kani/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
