{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rw-rs";
  version = "1.0.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jridgewell";
    repo = "rw";
    rev = "05f3e4f756aa69f9b85da76dbf723f8f620f90c1";
    hash = "sha256-0zvpcvypUhWp0nqHsj8vUSEwFOnCiAGIpMP3Neraugg=";
  };

  cargoHash = "sha256-/Jk8QUnUyrhEDAzbb7uQ2zQ5cshROHGd+iTMam0RjZE=";
  cargoPatches = [./Cargo.lock.patch];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Like sponge, but without the moreutils kitchen sink";
    homepage = "https://github.com/jridgewell/rw";
    license = lib.licenses.mit;
    mainProgram = "rw";
  };
})
