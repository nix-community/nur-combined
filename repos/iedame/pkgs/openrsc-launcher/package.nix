# The Open RuneScape Classic launcher, which downloads and starts the
# clients for the classic (2001-2004) RuneScape servers it lists, such as
# 2001scape, Preservation and Cabbage.
#
# Based on ArcticNimbat's package in NixOS/nixpkgs#460098 (not yet merged
# there); drop it here once nixpkgs has it.
{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  ant,
  jdk8,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openrsc-launcher";
  version = "5.30.0";

  src = fetchFromGitLab {
    owner = "openrsc";
    repo = "openrsc";
    tag = "ORSC-${finalAttrs.version}";
    hash = "sha256-9YurFfaAiB+noDXfe/7b0jEQxiluNqTOTXvdQITqq4E=";
  };

  sourceRoot = "${finalAttrs.src.name}/PC_Launcher";

  nativeBuildInputs = [
    ant
    jdk8
    makeWrapper
  ];

  env.JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF8";

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  # The games it downloads, and its settings, go in ~/.local/share/openrsc.
  # --no-update stops it replacing itself with a newer jar, which Nix
  # provides instead.
  installPhase = ''
    runHook preInstall
    install -Dm644 OpenRSC.jar $out/share/openrsc-launcher/OpenRSC.jar
    install -Dm644 vet.rsc.OpenRSC.Launcher.svg -t $out/share/pixmaps
    install -Dm644 vet.rsc.OpenRSC.Launcher.desktop -t $out/share/applications
    makeWrapper ${lib.getExe jdk8} $out/bin/openrsc \
      --add-flags "-jar $out/share/openrsc-launcher/OpenRSC.jar" \
      --add-flags '--dir "$HOME/.local/share/openrsc" --no-update'
    runHook postInstall
  '';

  meta = {
    description = "Free, open-source launcher for various Classic (2001-2004) RSC servers";
    homepage = "https://rsc.vet/";
    license = lib.licenses.agpl3Only;
    platforms = jdk8.meta.platforms;
    mainProgram = "openrsc";
  };
})
