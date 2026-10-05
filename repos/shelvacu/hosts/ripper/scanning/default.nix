{ config, pkgs, ... }:
let
  # raw scans with explicit exposure/gain/offset, for finding the right analog settings
  scan-raw-8400f =
    pkgs.writers.writePython3Bin "scan-raw-8400f"
      {
        libraries = [ pkgs.python3Packages.numpy ];
        flakeIgnore = [ "E501" ];
      }
      (
        builtins.replaceStrings
          [ "@scanimage@" ]
          [ "${config.hardware.sane.backends-package}/bin/scanimage" ]
          (builtins.readFile ./scan-raw-8400f.py)
      );
  # flat-fields scan-raw-8400f output against a white/dark reference into a linear 16-bit TIFF
  flatfield-8400f = pkgs.writers.writePython3Bin "flatfield-8400f" {
    libraries = [ pkgs.python3Packages.numpy ];
    flakeIgnore = [
      "E501"
      "W503"
    ];
  } (builtins.readFile ./flatfield-8400f.py);
in
{
  hardware.sane.enable = true;
  # SANE_GENESYS_8400F_NO_CALIBRATION=1 skips all calibration on the CanoScan 8400F (raw sensor
  # data, no hardware shading); unset, the backend behaves as normal.
  # SANE_GENESYS_8400F_{LPERIOD,EXPOSURE,AFE_GAIN,AFE_OFFSET} set the analog settings by hand
  # (calibration overwrites the AFE ones, so use them together with NO_CALIBRATION).
  hardware.sane.backends-package = pkgs.sane-backends.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./sane-genesys-8400f-no-calibration.patch ];
  });

  environment.systemPackages = [
    scan-raw-8400f
    flatfield-8400f
  ];

  users.groups.scanner.members = [
    "ripper"
    "shelvacu"
  ];

  vacu.packages = ''
    kdePackages.skanlite
    kdePackages.skanpage
    xsane
    simple-scan
    scantailor-universal
    scantailor-advanced

    gnumake
    imagemagick
    colord
  '';

  environment.pathsToLink = [
    # "/share/argyllcms"
    "/share/color"
  ];
}
