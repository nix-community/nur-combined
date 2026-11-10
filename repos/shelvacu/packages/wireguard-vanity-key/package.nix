{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "wireguard-vanity-key";
  version = "0-unstable-2025-09-16";

  src = fetchFromGitHub {
    owner = "AlexanderYastrebov";
    repo = "wireguard-vanity-key";
    rev = "8dc1554b7c917f9de6a254a581297302447fcc21";
    hash = "sha256-v4mWREA7jTBObganbNk3BNdTNG0YnU1hnXogmvjp3Xw=";
  };

  vendorHash = "sha256-ztbaNEE5fRuhMa1kmvR+e4A+3qi3y66Tz2jde3Jl8Og=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Find WireGuard key pairs with a specified public key prefix";
    homepage = "https://github.com/AlexanderYastrebov/wireguard-vanity-key";
    license = lib.licenses.bsd3;
    mainProgram = "wireguard-vanity-key";
  };
}
