{ bashNonInteractive
, coreutils
, fetchFromGitHub
, iproute2
, kmod
, lib
, makeWrapper
, maintainer
, stdenvNoCC
, unstableGitUpdater
,
}:

stdenvNoCC.mkDerivation rec {
  pname = "wondershaper";
  version = "0-unstable-2021-10-15";

  src = fetchFromGitHub {
    hash = "sha256-kt5f1dA3fSR5Xsuvh6ZvcY/SFeac8P9MAlwSAJ586W0=";
    owner = "magnific0";
    repo = "wondershaper";
    rev = "98792b55c2ebf4ab4cafffb0780e0c4185fdc03d";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;
  dontConfigure = true;

  postPatch = ''
    substituteInPlace wondershaper \
      --replace-fail '#!/usr/bin/env bash' '#!${bashNonInteractive}/bin/bash'
    substituteInPlace wondershaper.service \
      --replace-fail /usr/sbin/wondershaper "${builtins.placeholder "out"}/bin/wondershaper"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 wondershaper "$out/bin/wondershaper"
    install -Dm644 wondershaper.conf "$out/share/doc/wondershaper/wondershaper.conf"
    install -Dm644 wondershaper.service "$out/lib/systemd/system/wondershaper.service"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/wondershaper" \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        iproute2
        kmod
      ]}
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    versionOutput="$($out/bin/wondershaper -v)"
    case "$versionOutput" in
      *"Version 1.4.1"*) ;;
      *)
        echo "wondershaper -v returned unexpected output:" >&2
        echo "$versionOutput" >&2
        exit 1
        ;;
    esac

    # Full shaping commands require root and live network interfaces; check only non-mutating modes here.
    set +e
    helpOutput="$($out/bin/wondershaper -h 2>&1)"
    helpStatus=$?
    set -e
    if [ "$helpStatus" -ne 1 ]; then
      echo "wondershaper -h exited with status $helpStatus, expected 1" >&2
      echo "$helpOutput" >&2
      exit 1
    fi
    case "$helpOutput" in
      *"Limit the bandwidth of an adapter"*) ;;
      *)
        echo "wondershaper -h returned unexpected output:" >&2
        echo "$helpOutput" >&2
        exit 1
        ;;
    esac

    runHook postInstallCheck
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "master";
    url = "https://github.com/magnific0/wondershaper.git";
  };

  meta = {
    description = "Command-line utility for limiting an adapter's bandwidth";
    homepage = "https://github.com/magnific0/wondershaper";
    license = lib.licenses.gpl2Only;
    mainProgram = "wondershaper";
    maintainers = [ maintainer ];
    platforms = lib.platforms.linux;
  };
}
