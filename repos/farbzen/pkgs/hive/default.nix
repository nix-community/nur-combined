{
  lib,
  maintainers,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  git,
  colmena,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hive";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "farbzen";
    repo = "hive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hz80cryB2/1o7G8LOWGtK5HYnE1hux+um0krBDHI0Qc=";
  };

  cargoHash = "sha256-QfmfDTz1CERGVhhv4kQwaozsio3X4779OmE47AM7eOQ=";

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    for program in $out/bin/hive $out/bin/hive-tui; do
      wrapProgram "$program" --prefix PATH : ${lib.makeBinPath [git colmena]}
    done
  '';

  meta = {
    description = "Hive Infrastructure Versioning Engine - Deploying colmena hives and creating commits";
    homepage = "https://github.com/farbzen/hive";
    changelog = "https://github.com/farbzen/hive/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "hive";
    maintainers = [maintainers.farbzen];
  };
})
