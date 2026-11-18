{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mdatp";
  version = "101.26101.0000";
  ubuntuVersion = "26.04";

  src = fetchurl {
    url = "https://packages.microsoft.com/ubuntu/${finalAttrs.ubuntuVersion}/prod/pool/main/m/mdatp/mdatp_${finalAttrs.version}_amd64.deb";
    hash = "sha256-yh75kbygNeclWvHzMlibUYb9dXQdQ+qVNM3AM+Is7zg=";
  };

  nativeBuildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a opt $out/

    # Soname links normally created by the package's postinst.
    pushd $out/opt/microsoft/mdatp/lib
    ln -s libpcre2-8.so libpcre2-8.so.0
    ln -s libpcre2-posix.so.3.0.4 libpcre2-posix.so.3
    ln -s libnfnetlink.so.0.2.0 libnfnetlink.so.0
    ln -s libnetfilter_queue.so.1.5.0 libnetfilter_queue.so.1
    ln -s libmnl.so.0.2.0 libmnl.so.0
    ln -s libffi.so.8.1.0 libffi.so.8
    ln -s libglib-2.0.so.0.7302.0 libglib-2.0.so.0
    popd

    install -Dm644 $out/opt/microsoft/mdatp/resources/mdatp_completion.bash \
      $out/share/bash-completion/completions/mdatp
    install -Dm644 $out/opt/microsoft/mdatp/resources/mdatp_completion.zsh \
      $out/share/zsh/site-functions/_mdatp

    runHook postInstall
  '';

  # Binaries expect the FHS loader and /opt/microsoft/mdatp, and the daemon
  # verifies hashes of its bundled scripts: ship the payload unmodified.
  dontFixup = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Microsoft Defender for Endpoint on Linux";
    homepage = "https://learn.microsoft.com/defender-endpoint/microsoft-defender-endpoint-linux";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ codgician ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
