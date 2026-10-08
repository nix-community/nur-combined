{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  python3,
}:

let
  bazel_9 = stdenv.mkDerivation rec {
    pname = "bazel";
    version = "9.2.0";

    src = fetchurl {
      url = "https://github.com/bazelbuild/bazel/releases/download/${version}/bazel-${version}-linux-x86_64";
      hash = "sha256-dmipXbElDxLEBAclHk4gO07Ivzm8SV0vSFstjJkEhpQ=";
    };

    dontUnpack = true;

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/bazel
      chmod +x $out/bin/bazel
    '';
  };

  version = "0.1.2026100708";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    tag = "v${version}";
    hash = "sha256-8bjL/sB4WHrum1H8IDdL+P4msCzTBn92Ts2OuGhvV78=";
  };

  deps = stdenv.mkDerivation {
    name = "clice-deps";
    inherit src;
    
    nativeBuildInputs = [ bazel_9 python3 ];

    buildPhase = ''
      export HOME=$TMPDIR
      export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
      # Just fetch all external repositories
      bazel fetch //...
    '';

    installPhase = ''
      # The bazel cache is usually in $HOME/.cache/bazel
      cp -r $HOME/.cache/bazel $out
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

in
stdenv.mkDerivation {
  pname = "clice";
  inherit version src;

  nativeBuildInputs = [ bazel_9 python3 ];

  buildPhase = ''
    export HOME=$TMPDIR
    export BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
    
    # Copy the pre-fetched cache
    mkdir -p $HOME/.cache
    cp -r ${deps} $HOME/.cache/bazel
    chmod -R +w $HOME/.cache/bazel
    
    bazel build -c opt --config=RelWithDebInfo //...
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bazel-bin/bin/clice $out/bin/clice
  '';

  meta = with lib; {
    description = "Next-generation C++ language server built on LLVM/Clang";
    homepage = "https://github.com/clice-io/clice";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "clice";
  };
}
