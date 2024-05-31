{ fetchFromGitHub, fetchFromGitLab, flutter }:

rec {
  version = "2024-05-31";
  src = fetchFromGitLab {
    owner = "repos-holder";
    repo = "awl";
    rev = "9066b1ad59c22f7c5d6e7de060ebfbc2799afb09";
    sha256 = "sha256-oNNrqUtuFQSl3uBVzttsaXRWwVOFhODKRsymifLqyoN=";
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
