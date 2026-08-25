{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "pproftui";
  version = "0-unstable-2025-07-29";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Oloruntobi1";
    repo = "pproftui";
    rev = "d94a02c55dcdfc0bd2617acc9a1b98079bf990d8";
    hash = "sha256-idephYnsuwFrGBFGG4rG6bPa/WWBaYeddYOZezGBrv4=";
  };

  vendorHash = "sha256-1Rb0AZGWQo5hWHwX046R4jfCWBiljQ49eNK1krOmkTk=";

  ldflags = [ "-s" ];

  meta = {
    description = "A terminal-based diagnostic tool for Go pprof data";
    homepage = "https://github.com/Oloruntobi1/pproftui";
    license = lib.licenses.mit;
    mainProgram = "pproftui";
    maintainers = [ lib.maintainers.sikmir ];
  };
}
