{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pumpkin";
  version = "0.1.0-dev+2026-07-21";

  src = fetchFromGitHub {
    owner = "Pumpkin-MC";
    repo = "Pumpkin";
    rev = "afbe839dea58b6bc3b1e0ad983c9f75590ee9602";
    fetchSubmodules = true;
    hash = "sha256-rWZnxlOcIwPkTG9rHJ4pdjXLOczeZVmCHo2q/TJgrAA=";
  };

  cargoHash = "sha256-nobHvvbtAMgnOPuu3OYMwM+tNewH2X2gJEFS+BI4J+Y=";
  cargoBuildFlags = [
    "--package"
    "pumpkin"
  ];

  postInstall = ''
    ln -s pumpkin $out/bin/minecraft-server
  '';

  meta = {
    description = "Experimental Minecraft server implementation written in Rust";
    homepage = "https://pumpkinmc.org";
    changelog = "https://github.com/Pumpkin-MC/Pumpkin/commits/${finalAttrs.src.rev}";
    license = lib.licenses.gpl3Only;
    mainProgram = "pumpkin";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
