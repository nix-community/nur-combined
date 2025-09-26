{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "hoyolab-claim-bot";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = "hoyolab-claim-bot";
    rev = "v${version}";
    hash = "sha256-h39TSk2TRrAr8XhwvYHx0fiBAdBIa7pid83B39YEs3A=";
  };

  cargoHash = "sha256-BIU3TiNkSAwwlALZcekva+RpwM2GuQ/vP98WveiniHs=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Hoyolab daily claim bot for Hoyoverse games";
    homepage = "https://github.com/AtaraxiaSjel/hoyolab-claim-bot";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
