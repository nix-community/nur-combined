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
      "get-volume @DEFAULT_AUDIO_SINK@")
        printf 'Volume: 0.50\n'
        ;;
      "get-volume @DEFAULT_AUDIO_SOURCE@")
        printf 'Volume: 0.25 [MUTED]\n'
        ;;
      *)
        exit 1
        ;;
    esac
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
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    status=$(MENU_PROGRAM=rofi ./dmenu-wpctl --status)
    test "$status" = "󰕾 50% 󰍭"

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
