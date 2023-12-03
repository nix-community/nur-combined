{ lib, stdenv, buildGoModule, fetchFromGitHub, flutter }:

let
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
in buildGoModule rec {
  pname = "awl";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "anywherelan";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-lZv3XQmUGcroOWDPRSZ0I1eu3TH5J3AzsAYaHL5wBQ0=";
  };

  preBuild = ''
    cp -r ${awl_flutter} static
    rm -r cmd/awl-tray
  '';

  ldflags = [
    "-X github.com/anywherelan/awl/config.Version=v${version}"
  ];

  vendorHash = "sha256-3UY92eLHC9xG93JVT/Zv0Vd58z4jf2Njz5ktPPPgZww=";

  meta = with lib; {
    description = "Securely connect your devices into a private network";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
