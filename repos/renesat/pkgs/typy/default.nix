{
  fetchFromGitHub,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "typy";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "Pazl27";
    repo = "typy-cli";
    rev = "v${version}";
    hash = "sha256-BQQzs+M4IoXQOuUb9D0LJEBRSAo4evOyQFfwgMrT0NI=";
  };

  cargoHash = "sha256-z7jz51zalhfFo1hoMNhuhREa+piUkWppsdsEUdITU2g=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [openssl];

  meta = {
    description = "Minimalistic Monkeytype clone for the CLI";
    homepage = "https://github.com/Pazl27/typy-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
  };
}
