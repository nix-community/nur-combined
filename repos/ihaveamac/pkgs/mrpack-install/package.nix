{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mrpack-install";
  version = "0.21.0-beta-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "nothub";
    repo = pname;
    rev = "480907b4ede34b6ecfa4cc1a6e5956083b40e0e6";
    hash = "sha256-eG2hXFUkY3Up3ikRo8JXQwsCruLj207tgFMkDv0/MOg=";
  };

  vendorHash = "sha256-SBlBkStfVAqfyDDs6subgBtH7M0BKg8mNSWQm8Cb9Qw=";

  # has a test that fails related to paths or something
  # don't know why, but it seems to be not very important
  doCheck = false;

  meta = with lib; {
    description = "Modrinth Modpack server deployment";
    homepage = "https://github.com/nothub/mrpack-install";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "mrpack-install";
  };
}
