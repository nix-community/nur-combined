{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  fcitx5,
  protobuf,
  protobufc,
  qt6,
  hazkeyStable,
  llama-cpp,
}: let
  version = "unstable-2025-10-28";
in
  stdenv.mkDerivation {
    pname = "fcitx5-hazkey-git";
    inherit version;

    src = fetchFromGitHub {
      owner = "aster-void";
      repo = "fcitx5-hazkey-autocompile";
      rev = "a2ebdb42f8eae4adfb32479e7470d4518ce28593";
      hash = "sha256-PuFxKGjxenIRMDKFhVu4YcgUQYJeGsYv8yce2LqnNQc=";
    };

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [
      fcitx5
      protobuf
      protobufc
      qt6.qtbase
      stdenv.cc.cc.lib
      llama-cpp
    ];
    dontWrapQtApps = true;

    buildPhase = ''
      tar xvf dist/fcitx5-hazkey.tar.gz

      # Workaround: upstream dist leaves zenzai.gguf outside usr tree.
      mkdir -p usr/share/hazkey
      cp ${hazkeyStable}/share/hazkey/zenzai.gguf usr/share/hazkey/
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out $out/lib $out/bin

      mv ./usr/share $out/
      mv ./usr/lib/x86_64-linux-gnu/* $out/lib
      rm -f $out/lib/hazkey/llama-stub/libllama.so
      install -Dm755 ${llama-cpp}/lib/libllama.so $out/lib/hazkey/llama-stub/libllama.so
      for bin in hazkey-server hazkey-settings; do
        ln -s ../lib/hazkey/"$bin" "$out/bin/$bin"
      done

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/7ka-Hiira/fcitx5-hazkey";
      description = "Japanese input method for fcitx5, powered by azooKey engine";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "hazkey-settings";
    };
  }
