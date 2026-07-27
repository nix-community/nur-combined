{ pname
, version
, src
, autoPatchelfHook
, cprocsp-pki-cades
, dpkg
, gtk3
, lib
, libusb-compat-0_1
, libxcrypt-legacy
, linux-pam
, lsb-cprocsp-capilite
, lsb-cprocsp-rdr
, openssl_1_1
, pcsclite
, stdenv
, xorg
, zlib
}:

stdenv.mkDerivation {
  inherit pname version src;
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -R "$src" .
    runHook postUnpack
  '';
  postPatch = ''
    while read -r path ; do
      substituteInPlace "$path" \
        --replace "/etc/opt/cprocsp" "$out/etc" \
        --replace "/opt/cprocsp" "$out"
      substituteInPlace "$path" \
        --replace "$out/sbin/amd64/" "$out/sbin/" \
        --replace "$out/bin/amd64/" "$out/bin/" \
        --replace "$out/lib/amd64/" "$out/lib/"
    done < <(find -type f \(
      -iname '*.txt'
      -or -iname '*.desktop'
      -or -iname '*.service'
      \)
    )
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    libxcrypt-legacy.out
    openssl_1_1.out
    pcsclite
    stdenv.cc.cc.lib
    zlib
  ] ++ lib.optionals
    (builtins.elem pname [
      "cprocsp-cptools-gtk"
      "cprocsp-rdr-gui-gtk"
    ]) [
    gtk3
  ] ++ lib.optionals (pname == "cprocsp-cptools-gtk") [
    xorg.libXxf86vm
  ] ++ lib.optionals (pname != "lsb-cprocsp-rdr") [
    # libcapi10.so
    # librdrsup.so
    lsb-cprocsp-rdr
  ] ++ lib.optionals
    (builtins.elem pname [
      "cprocsp-apache-modssl"
      "cprocsp-certprop"
      "cprocsp-cptools-gtk"
      "cprocsp-curl"
      "cprocsp-legacy"
      "cprocsp-nginx"
      "cprocsp-pki-cades"
      "cprocsp-pki-plugin"
      "cprocsp-rdr-cloud"
      "cprocsp-stunnel"
      "cprocsp-stunnel-msspi"
      "lsb-cprocsp-pkcs11"
    ]) [
    # libcapi20.so
    lsb-cprocsp-capilite
  ] ++ lib.optionals (pname == "ifd-rutokens") [
    libusb-compat-0_1
  ] ++ lib.optionals (pname == "cprocsp-pki-plugin") [
    cprocsp-pki-cades
  ] ++ lib.optionals (pname == "cprocsp-stunnel") [
    linux-pam
  ] ++ lib.optionals (pname == "cprocsp-pki-cades") [
  ];

  autoPatchelfIgnoreMissingDeps = [
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out

    for prefix in lib bin sbin include src cpnginx ; do
      for f in opt/*/$prefix/* ; do
        mkdir -p $out/$prefix
        break
      done
      for f in opt/*/$prefix/amd64/* opt/*/$prefix/* ; do
        if [[ -e "$f" ]] ; then
          cp -r "$f" $out/$prefix/
          rm -rf "$f"
        fi
      done
    done

    for f in etc/opt/cprocsp/* ; do
      mkdir -p $out/etc
      break
    done
    for f in etc/opt/cprocsp/* ; do
      cp -r "$f" $out/etc/
    done

    for f in opt/* usr/share/* var/* ; do
      mkdir -p $out/share
      break
    done
    for f in opt/{aktivco,cprocsp,google}/share/* var/opt/cprocsp/* usr/share/* ; do
      cp -r "$f" $out/share/
      rm -rf "$f"
    done
    for f in opt/* usr/share/* ; do
      cp -r "$f" $out/share/
      rm -rf "$f"
    done

    runHook postInstall
  '';

  preFixup = ''
  '' + lib.optionalString (pname == "cprocsp-apache-modssl") ''
    patchelf --replace-needed libcrypto.so.1.0.2 libcrypto.so.1.1 $out/lib/astra_se_mod_ssl.so
    patchelf --replace-needed libssl.so.1.0.2 libssl.so.1.1 $out/lib/astra_se_mod_ssl.so
  '';

  postInstallCheck = ''
    ls -la usr/
  '';

  meta.description = "KGB-hijacked e-signature tools for interacting with the Russian tax authorities";
  meta.license = lib.licenses.unfree // { shortName = "Crypto-Pro"; };
  meta.maintainers = [ lib.maintainers.SomeoneSerge ];
  meta.platforms = [ "x86_64-linux" ];
  meta.sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
}
