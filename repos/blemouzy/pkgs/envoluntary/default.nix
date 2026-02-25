{
  lib,
  rustPlatform,
  fetchFromGitHub,
  bash,
}:

rustPlatform.buildRustPackage rec {
  pname = "envoluntary";
  version = "0.1.4-e2efbbe";

  src = fetchFromGitHub {
    owner = "dfrankland";
    repo = "envoluntary";
    rev = "e2efbbe5244191306c5ef0c9d4d64a377719b415";
    hash = "sha256-aD32BSoGyC26MX06k5Z3sHNvxy+QawH6jvjwG0JJvOk=";
  };

  cargoHash = "sha256-OxCm7kRdSbQl8pLgW9rBqDqmwirbaQPizv6NkJSjHmw=";

  preCheck = ''
    export NIX_BIN_BASH="${bash}/bin/bash"
  '';

  checkFlags = [
    "--"
    "--skip"
    "test_error_on_too_old_version"
  ];

  meta = {
    description = "Automatic Nix development environments for your shell";
    longDescription = ''
      Envoluntary seamlessly loads and unloads Nix development environments based on directory
      patterns, eliminating the need for per-project .envrc / flake.nix files while giving you
      centralized control over your development tooling.
    '';
    homepage = "https://github.com/dfrankland/envoluntary";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "envoluntary";
  };
}
