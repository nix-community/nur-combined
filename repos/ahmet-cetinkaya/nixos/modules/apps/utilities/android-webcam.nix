{config, pkgs, ...}: let
  androidWebcam = pkgs.writeShellScriptBin "android-webcam" ''
    set -euo pipefail

    device="''${1:-/dev/video2}"
    shift || true

    if [ ! -e "$device" ]; then
      echo "Virtual camera device not found: $device" >&2
      echo "Available video devices:" >&2
      ls /dev/video* 2>/dev/null >&2 || true
      exit 1
    fi

    exec ${pkgs.scrcpy}/bin/scrcpy \
      --v4l2-sink="$device" \
      --video-source=camera \
      --camera-facing="''${CAMERA_FACING:-front}" \
      --camera-size="''${CAMERA_SIZE:-1920x1080}" \
      --no-audio \
      "$@"
  '';
in {
  boot = {
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    # Pins the loopback device used by android-webcam.
    extraModprobeConfig = ''
      options v4l2loopback video_nr=2 card_label=AndroidCam exclusive_caps=1
    '';
  };

  environment.systemPackages = [androidWebcam];
}
