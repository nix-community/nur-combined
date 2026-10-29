# Microsoft Open Management Infrastructure (CIM server), as bundled by Dell.
{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  openssl,
  linux-pam,
  sources,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "omi";
  version = "1.9.1-0";
  __structuredAttrs = true;
  strictDeps = true;

  src = "${sources}/omi-${finalAttrs.version}.ssl_300.ulinux.s.x64.deb";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    openssl
    linux-pam
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/doc/omi
    cp -r opt/omi/bin opt/omi/lib $out
    cp opt/omi/LICENSE $out/share/doc/omi
    cp -r etc $out
    cp -r usr/share/selinux $out/share

    runHook postInstall
  '';

  passthru.updateScript = null; # proprietary, no public version feed

  meta = {
    description = "Open Management Infrastructure CIM server, as bundled with Dell Command | Monitor";
    homepage = "https://github.com/microsoft/omi";
    license = lib.licenses.unfree; # binary redistribution by Dell
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
