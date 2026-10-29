# Dell Hardware Abstraction Programming Interface.
{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  sources,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "srvadmin-hapi";
  version = "9.5.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = "${sources}/srvadmin-hapi_${finalAttrs.version}_amd64.deb";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt/dell/srvadmin/{etc,sbin,src} $out
    cp -r opt/dell/srvadmin/lib64 $out/lib
    cp -r usr/libexec $out
    cp -r usr/lib/systemd $out/lib
    cp -r etc/default $out/etc

    chmod +x $out/lib/*.so.${finalAttrs.version}

    # Done by postinst on every install.
    cat $out/etc/omreg.d/*.cfg > $out/etc/omreg.cfg

    runHook postInstall
  '';

  passthru.updateScript = null; # proprietary, no public version feed

  meta = {
    description = "Dell Hardware Abstraction Programming Interface";
    homepage = "https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "dchcfg";
  };
})
