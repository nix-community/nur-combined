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

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Boot and shutdown progress for systemd on the console";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    homepage = "https://codeberg.org/wvhulle/bootvine/";
    mainProgram = "bootvine";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
