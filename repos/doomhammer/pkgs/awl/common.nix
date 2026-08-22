{
  source,
  lib,
  darwin,
  flutter,
  stdenv,
}:
{
  inherit (source.awl) pname version src;
  awl_flutter = flutter.buildFlutterApplication rec {
    inherit (source.awl-flutter) pname version src;

    autoPubspecLock = "${src}/pubspec.lock";

    targetFlutterPlatform = "web";

    flutterBuildFlags = [
      "--release"
      "--no-web-resources-cdn"
      "--pwa-strategy=none"
      "--csp"
    ];

    nativeBuildInputs = lib.optionals stdenv.isDarwin [
      darwin.DarwinTools
    ];

  };
  patches = [ ];
}
