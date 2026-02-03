{
  lib,
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hexagon";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Master-Bw3";
    repo = "Hexagon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+g9VfNHAw+eQHG8rZycs+C6q5Fk9ZOAjdrYQKym53Xg=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ openssl ];

  cargoHash = "sha256-tnfXCIW6JNzv9Hozei3WbYkdig1zg7uUSv1n0I7vk8c=";

  passthru.updateScript = nix-update-script { };

  doCheck = false;

  meta = {
    name = "Hexagon";
    description = "Programming language for Hex Casting as a superset of the hexpattern format";
    homepage = "https://github.com/Master-Bw3/Hexagon";
    license = lib.licenses.mit;
    mainProgram = "hexagon";
  };
})
