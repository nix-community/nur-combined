{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wezterm-tabline";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "michaelbrusegard";
    repo = "tabline.wez";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1/lA0wjkvpIRauuhDhaV3gzCFSql+PH39/Kpwzrbk54=";
  };

  installPhase = ''
    runHook preInstall
    cp -R $src $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    files = runCommand "test-wezterm-tabline-files" { } ''
      test -s ${finalAttrs.finalPackage}/plugin/init.lua
      touch $out
    '';
  };

  meta = {
    description = "Tab-bar for WezTerm written in Lua";
    homepage = "https://github.com/michaelbrusegard/tabline.wez";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
