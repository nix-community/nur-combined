{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update,
  writeShellScript,
}:
stdenvNoCC.mkDerivation {
  pname = "hass-pun-sensor";
  version = "4.0.1-unstable-2026-04-18";

  src = fetchFromGitHub {
    owner = "virtualdj";
    repo = "pun_sensor";
    rev = "0792eee35454f27f77bba6419f6d5690e766e309";
    hash = "sha256-vyro2j+eddxg1cTKXLdmNXUDg9FZ5sIrqICwNSseLVo=";
  };

  # Home Assistant consumes this as a raw source tree: the config dir gets
  # `custom_components/pun_sensor` copied in by a tmpfiles rule, so the runtime
  # dependencies are resolved by the Home Assistant python env itself.
  # buildHomeAssistantComponent would only pull that whole env in for nothing.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r custom_components $out/
    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake hass-pun-sensor --version=branch";

  meta = {
    description = "Home Assistant integration exposing the Italian PUN electricity prices";
    homepage = "https://github.com/virtualdj/pun_sensor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
