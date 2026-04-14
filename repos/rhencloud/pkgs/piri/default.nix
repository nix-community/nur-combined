{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "piri";
  version = "unstable-2026-04-12";

  src = fetchFromGitHub {
    owner = "RhenCloud";
    repo = "piri";
    rev = "bc632a91fd543802d1c5ff847238749dde46a83e";
    hash = "sha256-IMC7HaPZmj/3yfqgBgTW2Shg0LJcWlraExyxUGe0Pfo=";
  };

  cargoHash = "sha256-lpmkDm2Xuc3/Xx+6i+pYAmQ2KzQxMD4YeQG203xgROc=";

  nativeBuildInputs = [
    pkg-config
  ];

  meta = with lib; {
    description = "Extend niri compositor capabilities with extensible command system and plugins";
    homepage = "https://github.com/RhenCloud/piri";
    license = licenses.mit;
    mainProgram = "piri";
    platforms = platforms.linux;
  };
}
