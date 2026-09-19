{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ponytail";
  version = "4.10.0";

  src = fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PES5XrSYx0VBXWVHEDRykGy0SAmJfV/luzy8Gfg0aAQ=";
  };

  postPatch = ''
    substituteInPlace hooks/claude-codex-hooks.json \
      --replace-fail '"command": "node ' '"command": "${lib.getExe nodejs} '
  '';

  buildInputs = [ nodejs ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ponytail
    cp -R .claude-plugin .codex-plugin commands hooks skills AGENTS.md LICENSE $out/share/ponytail/
    install -Dm644 assets/logo.png $out/share/ponytail/assets/logo.png
    chmod +x $out/share/ponytail/hooks/*.js $out/share/ponytail/hooks/*.sh
    patchShebangs --host $out/share/ponytail/hooks

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    files = runCommand "test-ponytail-files" { } ''
      test -s ${finalAttrs.finalPackage}/share/ponytail/skills/ponytail/SKILL.md
      test -s ${finalAttrs.finalPackage}/share/ponytail/skills/ponytail-review/SKILL.md
      test -s ${finalAttrs.finalPackage}/share/ponytail/.claude-plugin/plugin.json
      test -s ${finalAttrs.finalPackage}/share/ponytail/.codex-plugin/plugin.json
      test -s ${finalAttrs.finalPackage}/share/ponytail/commands/ponytail.toml
      test -s ${finalAttrs.finalPackage}/share/ponytail/hooks/claude-codex-hooks.json
      test -s ${finalAttrs.finalPackage}/share/ponytail/assets/logo.png
      touch $out
    '';
  };

  meta = {
    description = "Lazy senior dev mode skill for coding agents";
    homepage = "https://github.com/DietrichGebert/ponytail";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
