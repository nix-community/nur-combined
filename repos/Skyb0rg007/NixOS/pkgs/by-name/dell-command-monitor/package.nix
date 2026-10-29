{
  lib,
  stdenv,
  callPackage,
  dpkg,
  autoPatchelfHook,
  libusb1,
  libxml2_13,
  zlib,
  nixosTests,
}:
let
  sources = callPackage ./sources.nix { };
  omi = callPackage ./omi.nix { inherit sources; };
  srvadmin-hapi = callPackage ./srvadmin-hapi.nix { inherit sources; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dell-command-monitor";
  inherit (sources) version;
  __structuredAttrs = true;
  strictDeps = true;

  src = "${sources}/command-monitor_${finalAttrs.version}.ubuntu24_amd64.deb";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    omi
    srvadmin-hapi
    libusb1
    libxml2_13 # links against libxml2.so.2
    zlib
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/etc
    cp -r opt/dell/dcm/lib $out
    cp -r opt/dell/dcm/conf $out/etc/dcm

    runHook postInstall
  '';

  passthru = {
    inherit sources omi srvadmin-hapi;
    tests.nixos = nixosTests.dell-command-monitor;
    updateScript = null; # proprietary, no public version feed
  };

  meta = {
    description = "Dell Command | Monitor hardware monitoring agent";
    longDescription = ''
      OMI providers exposing Dell client system inventory, monitoring and
      alerting over CIM. Upstream registers them with
      `omireg -n root/dcim/sysman lib/libDellSysMgmtProv.so` (and
      `libDellSysMgmtAlertProv.so`).
    '';
    homepage = "https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
