{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  nibble-mlx-server,
}:
let
  appleSilicon = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
in
rustPlatform.buildRustPackage {
  pname = "nibble";
  version = "0.1.0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "nibble";
    rev = "c50e3c00a9c3b05ea2671d6d7acb8dd281d36fd0";
    hash = "sha256-YX5JjBvDEYHJOyTuoKYL74SxqYd6jZ+DGnbOHgE7B/o=";
  };

  cargoHash = "sha256-ONTyc4eReta426UB7WBQas+1ukAoOyHlcO/ipNko+kg=";

  # `nibble serve` starts nibble-mlx-server by name. Put it at the end of PATH,
  # so it works with no config file, and anything earlier on PATH still wins.
  # The server only exists on Apple silicon. Elsewhere nibble still builds,
  # and needs `server_command` set to some other OpenAI-style server.
  nativeBuildInputs = lib.optional appleSilicon makeWrapper;
  postFixup = lib.optionalString appleSilicon ''
    wrapProgram $out/bin/nibble --suffix PATH : ${nibble-mlx-server}/bin
  '';

  meta = {
    description = "A small local-model harness for tasks that don't need a big agent";
    homepage = "https://github.com/lillycham/nibble";
    license = lib.licenses.mit;
    mainProgram = "nibble";
  };
}
