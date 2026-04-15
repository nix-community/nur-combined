{
  sources,
  version,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  inherit version;

  cargoLock = sources.cargoLock."Cargo.lock";

  doCheck = false;

  postInstall = ''
    install -D package/krunner_zed.desktop $out/share/krunner/dbusplugins/krunner_zed.desktop
    install -D package/dev.algus.krunner_zed.service $out/share/dbus-1/services/dev.algus.krunner_zed.service
    substituteInPlace $out/share/dbus-1/services/dev.algus.krunner_zed.service \
      --replace-fail "Exec=" "Exec=$out/bin/krunner-zed"
  '';

  meta = {
    description = "KRunner plugin for zed";
    homepage = "https://github.com/hron/krunner-zed";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.mit;
  };
}
