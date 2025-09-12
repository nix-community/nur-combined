{
  lib,
  pkgs,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "ez-uploader";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "theMackabu";
    repo = pname;
    rev = "227c3741fe3a968273176a68cdb1884ef4b1d93c";
    hash = "sha256-J/Pwh7Qy0JEvCcpKYwnoDOXCCAczUR3t6jAQObesWVY=";
  };
  buildInputs = with pkgs; [ openssl ];
  nativeBuildInputs = with pkgs; [ pkg-config ];
  cargoHash = "sha256-6GYEz6wAedIfqD2fL4d4dfhXWTSJ8uhx7v4jID6FhK0=";
  meta = {
    description = "CLI tool for interacting directly with the e-z.host API.";
    homepage = "https://github.com/themackabu/ez-uploader";
    license = lib.licenses.mit;
    mainProgram = "ez";
  };
}
