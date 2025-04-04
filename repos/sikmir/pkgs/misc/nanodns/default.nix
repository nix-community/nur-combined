{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "nanodns";
  version = "0-unstable-2021-10-29";

  src = fetchFromGitHub {
    owner = "Sina-Ghaderi";
    repo = "nanodns";
    rev = "fb0c62f7123cb39c0e327ff1515536ce2ed6c3db";
    hash = "sha256-Paz59YJkwK0v9/e7NrqpQjx0r/iHMpSCLd2heHw8KlA=";
  };

  patches = [ ./go.mod.patch ];

  vendorHash = "sha256-+azMCvpNBE6p+U9wHdl8j5pKV42v05PIkeOURB+5qVc=";

  meta = {
    description = "Simple dns forwarder/cache blocker server";
    homepage = "https://github.com/Sina-Ghaderi/nanodns";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
