{ fetchFromGitHub, fetchFromGitLab, flutter }:

rec {
  version = "0.10.0";
  src = fetchFromGitLab {
    owner = "repos-holder";
    repo = "awl";
    rev = "37a343ffa522a6e74be31d73420ef04515321fde";
    sha256 = "sha256-oNNrqUtuFQSl3uBVzttsaXRWwVOFhODKRsymifLqyoM=";
  };
 awl_flutter = (flutter.buildFlutterApplication  rec {
    pname = "awl-flutter";
    version = "0.6.0";

    src = fetchFromGitHub {
      owner = "anywherelan";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-zlROkCfJsOFH9TnwJcHSpx9CByhjVDWAtMLIAI8I5Jo=";
    };

    depsListFile = ./deps.json;
    vendorHash = "sha256-ko1pxFDGm1Mtlqr/GsqVApKrOlDZp6Dii8FqVjC6NtQ=";
  }).overrideAttrs (oldAttrs: {
    outputs = [ "out" ];

    buildPhase = ''
      runHook preBuild

      doPubGet flutter pub get --offline -v
      flutter build web -v --release
      rm -rf build/web/canvaskit

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mv build/web $out

      runHook postInstall
    '';
  });
}
