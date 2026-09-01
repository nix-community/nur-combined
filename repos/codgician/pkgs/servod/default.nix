{
  lib,
  stdenvNoCC,
  fetchgit,
  makeWrapper,
  bash,
  coreutils,
  docker-client,
  gnugrep,
  gnutar,
}:

stdenvNoCC.mkDerivation {
  pname = "servod";
  version = "unstable-2026-08-19";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/third_party/hdctools";
    rev = "4b3f87f839688ad00c50232f81c7a7d6807cf452";
    hash = "sha256-VIwE2wZ+J1cTTN9m9Lej2daezUhYn+ZmVJAA1CC3Qm8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/hdctools" "$out/bin"
    cp -r scripts development_environment "$out/libexec/hdctools/"
    patchShebangs "$out/libexec/hdctools"

    for command in \
      start-servod \
      stop-servod \
      dut-control \
      servod-ps \
      servodtool \
      servo-updater
    do
      if [[ -x "$out/libexec/hdctools/scripts/$command" ]]; then
        install -m755 scripts/start-servod "$out/libexec/hdctools/scripts/$command"
        substituteInPlace "$out/libexec/hdctools/scripts/$command" \
          --replace-fail \
            'image_exists=$(docker images -q servod-bootstrap:latest 2> /dev/null)' \
            'cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/chromeos-servod"; mkdir -p "$cache_dir"; checksum_file="$cache_dir/bootstrap-checksum"; image_exists=$(docker images -q servod-bootstrap:latest 2> /dev/null)' \
          --replace-fail '[ ! -f checksum ]' '[ ! -f "$checksum_file" ]' \
          --replace-fail '"$(cat checksum)"' '"$(cat "$checksum_file")"' \
          --replace-fail 'echo "''${checksum}" > checksum' 'echo "''${checksum}" > "$checksum_file"'
        sed -i '1s|^#!/bin/bash$|#!${lib.getExe bash}|' \
          "$out/libexec/hdctools/scripts/$command"
        makeWrapper "$out/libexec/hdctools/scripts/$command" "$out/bin/$command" \
          --prefix PATH : ${
            lib.makeBinPath [
              bash
              coreutils
              docker-client
              gnugrep
              gnutar
            ]
          } \
          --set-default DOCKER_HOST unix:///var/run/docker.sock
      fi
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x "$out/bin/start-servod"
    test -x "$out/bin/dut-control"
    test -x "$out/bin/stop-servod"

    runHook postInstallCheck
  '';

  meta = {
    description = "Container-backed ChromeOS servod hardware-debugging wrappers";
    homepage = "https://chromium.googlesource.com/chromiumos/third_party/hdctools/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "start-servod";
  };
}
