# <https://github.com/estkme-group/lpac>
# Local Profile Agent
# allows configuring eSIM profiles on a SIM card attached via USB, or a modem.
# in the case of USB, it depends on pcscd (Personal Computer/Smart Card daemon) from pcsclite package
#   (which i enable below).
#   - <https://salsa.debian.org/rousseau/PCSC>
#
# use like:
# - LPAC_APDU=pcsc lpac driver apdu list
#
# GUI apps built atop lpac:
# - easylpac
# - lpa-gtk
#
# known environment variables:
# - LPAC_CUSTOM_ES10X_MSS
# - LPAC_CUSTOM_ISD_R_AID
# - LPAC_APDU_DEBUG
# - LPAC_APDU_HTTP
# - LPAC_APDU=...
#   at, at_csim, pcsc, stdio, qmi, qmi_qrtr, uqmi, mbim, gbinder
# - LPAC_HTTP=...
#   curl, winhttp, stdio
# - LPAC_APDU_PCSC_DRV_IFID
# - LPAC_APDU_PCSC_DRV_NAME
# - LPAC_APDU_PCSC_DRV_IGNORE_NAME
{ config, lib, ... }:
let
  cfg = config.sane.programs.lpac;
in
{
  sane.programs.lpac = {
    sandbox.extraPaths = [
      "/run/pcscd"  #< to communicate with the daemon
    ];

    # settings for using the eSIM adapter (will likely need changing for physical SIM or eSIM)
    env.LPAC_APDU = "pcsc";
  };

  services.pcscd = lib.mkIf cfg.enabled {
    # TODO: sandbox this service!
    enable = true;
    extraArgs = [ "--debug" ];
  };

  # pcscd polkit docs: <https://salsa.debian.org/rousseau/PCSC/-/blob/master/doc/README.polkit>
  security.polkit.extraConfig = lib.mkIf cfg.enabled ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.debian.pcsc-lite.access_card" &&
        subject.user == "colin"
      ) {
        return polkit.Result.YES;
      }
    });

    polkit.addRule(function(action, subject) {
      if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
        subject.user == "colin"
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
