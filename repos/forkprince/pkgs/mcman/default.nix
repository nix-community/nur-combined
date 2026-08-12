# NOTE: Based on the official flake (https://github.com/deniz-blue/mcman/blob/main/flake.nix)
{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  lib,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "mcman";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "deniz-blue";
    repo = "mcman";
    tag = version;
    hash = "sha256-/WIm2MFj2++QVCATDkYz2h4Jm+0RzxzVFIYrZubEgIQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "mcapi-0.2.0" = "sha256-wHXA+4DQVQpfSCfJLFuc9kUSwyqo6T4o0PypYdhpp5s=";
      "pathdiff-0.2.1" = "sha256-+X1afTOLIVk1AOopQwnjdobKw6P8BXEXkdZOieHW5Os=";
      "rpackwiz-0.1.0" = "sha256-pOotNPIZS/BXiJWZVECXzP1lkb/o9J1tu6G2OqyEnI8=";
    };
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [openssl];

  postInstall = ''
    cp -r $src/res $out/res
  '';

  meta = {
    description = "Powerful Minecraft Server Manager CLI";
    homepage = "https://github.com/deniz-blue/mcman";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux;
    mainProgram = "mcman";
  };
}
