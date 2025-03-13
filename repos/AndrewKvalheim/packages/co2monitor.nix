{ buildGoModule
, fetchFromGitHub
, lib
, writeText
}:

let
  rules = writeText "co2monitor.rules" ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", MODE="0660", TAG+="uaccess", GROUP="co2monitor", SYMLINK+="co2monitor", TAG+="systemd", ENV{SYSTEMD_ALIAS}+="/dev/co2monitor"
  '';
in
buildGoModule {
  pname = "co2monitor";
  version = "0-unstable-2021-08-10";

  src = fetchFromGitHub {
    owner = "larsp";
    repo = "co2monitor";
    rev = "1f7644b19d340fc3cc62edc9f949ad85e610fc51"; # PR #4
    hash = "sha256-OrZd4x4FGastHUQdety/3z5POI3NDWRQqNZb5t1yzEU=";
  };

  vendorHash = "sha256-WsNFsAAfaORA9EyRuBt3gqv+6MyZ2amSYtVdNCo6ps8=";

  postInstall = "install -D ${rules} $out/etc/udev/rules.d/50-co2monitor.rules";

  doCheck = false; # Requires hardware

  meta = {
    description = "CO₂ and temperature monitor";
    homepage = "https://github.com/larsp/co2monitor";
    license = lib.licenses.mit;
    mainProgram = "co2monitor";
  };
}
