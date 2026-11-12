{
  lib,
  stdenvNoCC,
  bash,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  ipmitool,
  lm_sensors,
  makeWrapper,
  perl,
  sources,
}:
let
  perlWithSSL = perl.withPackages (ps: [ ps.IOSocketSSL ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dell-idrac-fan-controller";
  inherit (sources.dell-idrac-fan-controller) src version;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    scriptDir="$out/libexec/dell-idrac-fan-controller"
    install -Dm755 -t "$scriptDir" Dell_iDRAC_fan_controller.sh supervisor.sh
    install -Dm644 -t "$scriptDir" functions.sh constants.sh
    install -Dm644 -t "$out/share/doc/${finalAttrs.pname}" LICENSE LICENSE-COMMERCIAL.md NOTICE README.md

    # Upstream resolves these paths relative to the container's /app working directory.
    substituteInPlace "$scriptDir/Dell_iDRAC_fan_controller.sh" "$scriptDir/supervisor.sh" \
      --replace-fail 'source functions.sh' "source $scriptDir/functions.sh" \
      --replace-fail 'source constants.sh' "source $scriptDir/constants.sh"
    substituteInPlace "$scriptDir/supervisor.sh" \
      --replace-fail 'bash ./Dell_iDRAC_fan_controller.sh' "${lib.getExe bash} $scriptDir/Dell_iDRAC_fan_controller.sh"
    patchShebangs "$scriptDir"

    makeWrapper "$scriptDir/supervisor.sh" "$out/bin/dell-idrac-fan-controller" \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          gawk
          gnugrep
          gnused
          ipmitool
          lm_sensors
          perlWithSSL
        ]
      } \
      --set-default IDRAC_HOST local \
      --set-default FAN_SPEED 5 \
      --set-default CPU_TEMPERATURE_THRESHOLD auto \
      --set-default CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION 30 \
      --set-default CPU_TEMPERATURE_SOURCE auto \
      --set-default CHECK_INTERVAL 5 \
      --set-default MAXIMUM_IPMI_UNREACHABLE_DURATION 60s \
      --set-default MAXIMUM_CONSECUTIVE_IPMI_FAILURES "" \
      --set-default DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE false \
      --set-default KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT false \
      --set-default MONITORING_ONLY_MODE false

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    for script in "$out/libexec/dell-idrac-fan-controller/"*.sh; do
      ${lib.getExe bash} -n "$script"
    done
    ${lib.getExe perlWithSSL} -MHTTP::Tiny -MIO::Socket::SSL -e 1

    runHook postInstallCheck
  '';

  meta = {
    description = "Control Dell PowerEdge fan speed based on CPU temperatures through iDRAC/IPMI";
    homepage = "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux;
    mainProgram = "dell-idrac-fan-controller";
  };
})
