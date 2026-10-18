{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  makeWrapper,
  wireplumber,
  writeShellScriptBin,
}:

let
  testWpctl = writeShellScriptBin "wpctl" ''
    case "$*" in
      "get-volume @DEFAULT_AUDIO_SINK@"|"get-volume 42")
        printf 'Volume: 0.50\n'
        ;;
      "get-volume @DEFAULT_AUDIO_SOURCE@"|"get-volume 43")
        printf 'Volume: 0.25 [MUTED]\n'
        ;;
      status)
        printf '%s\n' \
          'Audio' \
          ' ├─ Sinks:' \
          ' │  * 42. Speaker [vol: 0.50]' \
          ' ├─ Sources:' \
          ' │  * 43. Microphone [vol: 0.25]' \
          'Video' \
          'Settings'
        ;;
      *)
        exit 1
        ;;
    esac
  '';
  testMenu = writeShellScriptBin "rofi" ''
    cat > "$TEST_MENU_CAPTURE"
    printf 'Exit\n'
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dmenu-wpctl";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "iamanaws";
    repo = "dmenu-wpctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vPJXH2Lqnw/wJkOZCQ0u3o6O4tOjF0oEDV7TfQLzNwU=";
  };

  postPatch = ''
    patchShebangs ./dmenu-wpctl
  '';

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    gawk
    gnugrep
    testWpctl
    testMenu
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    status=$(MENU_PROGRAM=rofi ./dmenu-wpctl --status)
    test "$status" = "󰕾 50% 󰍭"

    TEST_MENU_CAPTURE="$PWD/menu.txt" MENU_PROGRAM=rofi ./dmenu-wpctl --audio
    menu=$(<menu.txt)
    [[ "$menu" == *$'Output Devices:\n  [42] Speaker (50%)\n\nInput Devices:\n'* ]]

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ./dmenu-wpctl $out/bin/dmenu-wpctl
    wrapProgram $out/bin/dmenu-wpctl \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          findutils
          gawk
          gnugrep
          gnused
          wireplumber
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Audio/Video control menu for WirePlumber";
    longDescription = ''
      Interactive menu interface to manage audio and video devices
      using wpctl (WirePlumber) and dmenu-compatible programs.
    '';
    homepage = "https://github.com/iamanaws/dmenu-wpctl";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "dmenu-wpctl";
    platforms = lib.platforms.linux;
  };
})
