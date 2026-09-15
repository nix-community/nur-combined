{
  fetchzip,
  lib,
  nix-update-script,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  pname = "wsl-notify-send";
  version = "0.1.871612270";

  # --- Source Binary ---
  exe = fetchzip {
    url = "https://github.com/stuartleeks/wsl-notify-send/releases/download/v${version}/wsl-notify-send_windows_amd64.zip";
    hash = "sha256-ORvJbxkSw9Y3QAK9RCmfB6T3Ef8W0HKoJKDO2gGKQ4A=";
    stripRoot = false;
  };

  # --- Wrappers ---
  # notify-send compatibility wrapper combining SUMMARY and BODY
  notify-send-wrapper = writeShellScriptBin "notify-send" ''
    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
      case $1 in
        --)
          shift
          POSITIONAL+=("$@")
          break
          ;;
        -u|--urgency|-t|--expire-time|-i|--icon|-c|--category|-h|--hint|-a|--app-name|-r|--replace-id)
          shift $(( $# >= 2 ? 2 : 1 ))
          ;;
        --urgency=*|--expire-time=*|--icon=*|--category=*|--hint=*|--app-name=*|--replace-id=*)
          shift 1
          ;;
        -*)
          shift 1
          ;;
        *)
          POSITIONAL+=("$1")
          shift 1
          ;;
      esac
    done

    if [[ ''${#POSITIONAL[@]} -eq 0 ]]; then
      MESSAGE=""
    elif [[ ''${#POSITIONAL[@]} -eq 1 || -z "''${POSITIONAL[*]:1}" ]]; then
      MESSAGE="''${POSITIONAL[0]}"
    else
      MESSAGE="''${POSITIONAL[0]}: ''${POSITIONAL[*]:1}"
    fi

    if [[ -z "$MESSAGE" ]]; then
      echo "Usage: notify-send [OPTIONS] SUMMARY [BODY]" >&2
      exit 1
    fi

    DISTRO="''${WSL_DISTRO_NAME:-WSL}"
    exec "${exe}/wsl-notify-send.exe" --appId "$DISTRO" --category "$DISTRO" "$MESSAGE"
  '';

  # Native wsl-notify-send executable wrapper
  wsl-notify-send = writeShellScriptBin "wsl-notify-send" ''
    exec "${exe}/wsl-notify-send.exe" "$@"
  '';
in
symlinkJoin {
  inherit pname version;
  preferLocalBuild = false;
  paths = [
    notify-send-wrapper
    wsl-notify-send
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Send Windows 10/11 toast notifications from WSL";
    homepage = "https://github.com/stuartleeks/wsl-notify-send";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "notify-send";
  };
}
