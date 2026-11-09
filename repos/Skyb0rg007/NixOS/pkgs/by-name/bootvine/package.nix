{
  lib,
  fetchFromCodeberg,
  rustPlatform,
  pkg-config,
  dbus,
  systemdLibs,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bootvine";
  version = "0.1.3";
  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "wvhulle";
    repo = "bootvine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WzqLbOcOokwn2XT62YdD3llWZbNhMl/STbJb2Yn2/pQ=";
  };

  cargoHash = "sha256-uoWys8kdGUZ3YeriNLsU8we/kSTvCswQkzdnhTIEtCY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    systemdLibs
  ];

  cargoBuildFlags = [
    "--package=bootvine"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  postInstall = ''
    for unit in \
      bootvine.service \
      bootvine-shutdown.service \
      systemd-hibernate-resume.service.d/bootvine.conf
    do
      install -Dm644 bootvine/system-files/systemd/$unit $out/lib/systemd/system/$unit
      substituteInPlace $out/lib/systemd/system/$unit \
        --replace-fail /usr/bin/bootvine $out/bin/bootvine
    done
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Boot and shutdown progress for systemd on the console";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    homepage = "https://codeberg.org/wvhulle/bootvine/";
    changelog = "https://codeberg.org/wvhulle/bootvine/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    mainProgram = "bootvine";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
