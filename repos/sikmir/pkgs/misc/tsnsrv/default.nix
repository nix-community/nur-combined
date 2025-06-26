{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "tsnsrv";
  version = "0-unstable-2025-06-05";

  src = fetchFromGitHub {
    owner = "boinkor-net";
    repo = "tsnsrv";
    rev = "e2537464e45db0f173e8e68d0316b40c13e1e49c";
    hash = "sha256-tVHkh0AGDl+de9itdLsi3lfMOyOLyQjtnp1zw2zyYV8=";
  };

  subPackages = [ "cmd/tsnsrv" ];

  vendorHash = "sha256-iGW7+jpxfM421RYvmaqaOJ/wKeJDkXn7baHZXYkAqEk=";

  meta = {
    description = "A reverse proxy that exposes services on your tailnet";
    homepage = "https://github.com/boinkor-net/tsnsrv";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tsnsrv";
  };
}
