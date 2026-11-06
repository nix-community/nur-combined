{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  gitMinimal,
  lsof,
  procps,
}:
let
  runtimePath =
    lib.makeBinPath (
      [ gitMinimal lsof ] ++ lib.optional stdenv.hostPlatform.isLinux procps
    )
    + lib.optionalString stdenv.hostPlatform.isDarwin ":/bin";
in
rustPlatform.buildRustPackage rec {
  pname = "why";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "why";
    rev = "7cb1d906178bcbc86df6927efedf3dd204ed4711";
    hash = "sha256-wY8GY62rESCTRyJMqHSfk7YLpp/D38HxDu2uJ6D/DcY=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ makeWrapper ];
  # Preserve the caller's command lookup order. macOS provides ps in /bin.
  # Use the host's nix-store rather than adding another Nix implementation.
  postFixup = ''
    wrapProgram $out/bin/why --suffix PATH : ${runtimePath}
  '';

  meta = {
    description = "Explain why a file, command or listening port is on this machine";
    homepage = "https://github.com/lillycham/why";
    license = lib.licenses.mit;
    mainProgram = "why";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
