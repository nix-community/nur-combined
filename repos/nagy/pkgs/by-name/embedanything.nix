{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  cmake,
  stdenv,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "embedanything";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "StarlightSearch";
    repo = "EmbedAnything";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1wFHYSYiyc7oGEUEfTywvyLORbpCxLluC3BYT9Y0tCc=";
  };

  cargoHash = "sha256-XKkHqRLjRwFhcvzWh7tuOQ0VXG0jZ3YLLFaqf+lGGOg=";

  # The `server` binary is defined in the `server` workspace member. Build only
  # that package to avoid compiling the unused Python/maturin and example code.
  cargoBuildFlags = [ "--package" "server" ];
  cargoTestFlags = [ "--package" "server" ];

  # Examples and tests require runtime model downloads (from_pretrained_hf),
  # so disable the test harness.
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    openssl
  ];

  # The upstream `server` crate names its binary `server`. Rename it to a more
  # descriptive name for the package output.
  postInstall = ''
    mv $out/bin/server $out/bin/embedanything
  '';

  meta = {
    description = "Embed anything at lightning speed";
    longDescription = ''
      Highly performant, modular and memory-safe embeddings for documents,
      images and audio, built in Rust. This package builds the HTTP server.
    '';
    homepage = "https://github.com/StarlightSearch/EmbedAnything";
    license = with lib.licenses; asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "embedanything";
  };
})
