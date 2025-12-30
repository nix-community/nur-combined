{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "homescript";
  version = "0-unstable-2025-12-22";

  src = fetchFromGitHub {
    owner = "homescript-dev";
    repo = "server";
    rev = "ca3be6e6fe0fbf9fb138215ce5868f191e2513fd";
    hash = "sha256-aquUvoZBrvDzhGTb+VqFgK9vLhGrvoFszmksMIbjlN0=";
  };

  vendorHash = "sha256-2nMOndl5v4B/nNK06jVp6OWsPazXj2VCiXYhVJ0VHKk=";

  postInstall = ''
    mv $out/bin/{,homescript-}server
  '';

  meta = {
    description = "Homescript Server";
    homepage = "https://github.com/homescript-dev/server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
