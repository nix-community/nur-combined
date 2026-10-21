{
  lib,
  stdenvNoCC,
  source,
  python3,
}:
stdenvNoCC.mkDerivation {
  pname = "docker-systemctl-replacement";
  inherit (source) src version;

  buildInputs = [python3];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 files/docker/systemctl3.py $out/bin/systemctl3
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/systemctl3 --version | grep -F 'via systemctl.py ${source.version}'

    runHook postInstallCheck
  '';

  meta = {
    description = "Run systemd units without systemd, as systemctl and init inside containers";
    homepage = "https://github.com/gdraheim/docker-systemctl-replacement";
    changelog = "https://github.com/gdraheim/docker-systemctl-replacement/blob/v${source.version}/RELEASENOTES.md";
    license = lib.licenses.eupl12;
    mainProgram = "systemctl3";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.linux;
  };
}
