{
  buildGo125Module,
  lib,
  source,
  version,
  zip,
}:

buildGo125Module {
  pname = "winboat-guest-server";
  inherit version;
  inherit (source) src;

  modRoot = "guest_server";
  vendorHash = "sha256-NjjQINg+qh5zsGoPlpbw9Ib29+KhIuSYXPr6fU+JZjg=";

  env = {
    GOOS = "windows";
    GOARCH = "amd64";
    PACKAGE = "winboat-server";
  };

  subPackages = [
    "cmd/server"
    "cmd/updater"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.CommitHash=${lib.substring 0 7 source.src.rev}"
    "-X main.BuildTimestamp=${source.date}T00:00:00"
  ];

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/oem/server/scripts" \
      "$out/oem/updater" \
      "$out/update"

    install -Dm755 \
      "$GOPATH/bin/server.exe" \
      "$out/oem/server/winboat_guest_server.exe"
    install -Dm755 \
      "$GOPATH/bin/updater.exe" \
      "$out/oem/updater/winboat_guest_server_updater.exe"

    install -Dm644 \
      scripts/apps.ps1 \
      scripts/get-icon.ps1 \
      scripts/time-sync.bat \
      "$out/oem/server/scripts/"
    install -Dm644 \
      install.bat \
      nssm.exe \
      RDPApps.reg \
      "$out/oem/"

    (
      cd "$out/oem/server"
      zip -r -q "$out/update/winboat_guest_server.zip" .
    )

    runHook postInstall
  '';

  meta = {
    description = "Guest server and updater for WinBoat";
    homepage = "https://github.com/TibixDev/winboat";
    changelog = "https://github.com/TibixDev/winboat/commit/${source.src.rev}";
    license = lib.licenses.mit;
    platforms = [ "x86_64-windows" ];
  };
}
