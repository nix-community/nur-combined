{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update,
  writeShellScript,
}:
stdenvNoCC.mkDerivation {
  pname = "hass-garmin-connect";
  version = "3.0.16-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "home-assistant-garmin_connect";
    rev = "94b917aa889cf75296fec9849e9263d18d132f62";
    hash = "sha256-GHwGogWAlugqWMndJ1C/UaYITy+hrOF+G5rKW5OXNEI=";
  };

  # Home Assistant consumes this as a raw source tree: the config dir gets
  # `custom_components/garmin_connect` copied in by a tmpfiles rule, so the
  # runtime dependencies are resolved by the Home Assistant python env itself.
  # buildHomeAssistantComponent would only pull that whole env in for nothing.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r custom_components $out/
    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake hass-garmin-connect --version=branch";

  meta = {
    description = "Home Assistant integration exposing and uploading Garmin Connect data";
    homepage = "https://github.com/cyberjunky/home-assistant-garmin_connect";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
