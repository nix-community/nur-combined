{ fetchFromGitHub, flutter }:

rec {
  version = "0.10.0";
  src = fetchFromGitHub {
    owner = "anywherelan";
    repo = "awl";
    rev = "v${version}";
    sha256 = "sha256-lZv3XQmUGcroOWDPRSZ0I1eu3TH5J3AzsAYaHL5wBQ0=";
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
  patches = [ ./router.patch ./listen.patch ];
}
