##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  patchelf,
  makeWrapper,
  unzip,
  zstd,
  buildFHSEnv,
  pcsclite,
  openssl_3_6,
  webkitgtk_4_1,
  gtk3,
  glib,
  libnotify,
  libappindicator-gtk3,
  libxml2,
  fontconfig,
  freetype,
  libpng,
  bzip2,
  expat,
  brotli,
  zlib,
  libx11,
  libxext,
  libxrender,
  libxtst,
  libxi,
  python3,
  zenity
}:

let
  version = "26.08";
  zipArchive = fetchurl {
    url = "https://misc.jorgearaya.dev/sfd_ClientesLinux_DEB64_Ubuntu24_rev26_08.zip";
    hash = "sha256-DoTSESDCyb5/QZkh7oXR73Xn1uEZry6RaKzbPfG4TFI=";
  };

  idopteDebPath = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Idopte/Idopte_6.23.50.5_ubun24_amd64.deb";
  gaudiDebPath = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Agente GAUDI/agente-gaudi_29.0_amd64.deb";
  pkcs11Dir = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Librer*/x64";
  certsDir = "sfd_ClientesLinux_DEB64_Ubuntu24_26_08/Firma Digital/Certificados";

  extractDeb =
    { name, debPath }:
    stdenv.mkDerivation {
      name = "${name}-extracted-${version}";
      src = zipArchive;
      nativeBuildInputs = [
        unzip
        zstd
      ];
      unpackPhase = ''
        runHook preUnpack
        mkdir -p $out
        unzip -p $src '${debPath}' > $name.deb
        ar x $name.deb data.tar.xz data.tar.zst 2>/dev/null || true
        if [ -f data.tar.zst ]; then
          tar --use-compress-program=zstd -xf data.tar.zst -C $out
        elif [ -f data.tar.xz ]; then
          tar -xf data.tar.xz -C $out
        fi
        runHook postUnpack
      '';
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
    };

  idopteExtracted = extractDeb {
    name = "idopte";
    debPath = idopteDebPath;
  };
  gaudiExtracted = extractDeb {
    name = "agente-gaudi";
    debPath = gaudiDebPath;
  };

  commonMeta = {
    homepage = "https://www.soportefirmadigital.com";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ elzorrorebelde ];
    platforms = lib.platforms.linux;
  };

  # The DEB's bundled .so files (libpodofo, libxmlsec1, libdigidoc) were
  # linked against libxml2.so.2 (Ubuntu 24.04 ABI). Nixpkgs ships
  # libxml2.so.16 (2.15.x). Symlink the SONAME the binaries expect;
  # libxml2's public API/ABI for the symbols used here is stable across
  # this range, only the SONAME policy changed upstream.
  libxml2-compat = stdenv.mkDerivation {
    name = "libxml2-compat-${version}";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/lib
      ln -s ${lib.getLib libxml2}/lib/libxml2.so.16 $out/lib/libxml2.so.2
      ln -s ${lib.getLib libxml2}/lib/libxml2.so.16 $out/lib/libxml2.so.2.15.4
    '';
  };
in
rec {
  # ── CA Certificates ───────────────────────────────────────────────────

  ca-certificates = stdenv.mkDerivation {
    pname = "firma-digital-cr-ca-certificates";
    inherit version;
    src = zipArchive;
    nativeBuildInputs = [ unzip openssl_3_6 ];

    unpackPhase = ''
      runHook preUnpack
      mkdir -p certs
      unzip -o -j $src '${certsDir}/*' -d certs
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/etc/ssl/certs
      cp certs/* $out/etc/ssl/certs/

      # ponytail: one-liner DER→PEM conversion. If openssl ever
      # chokes on a file, add `|| true` to skip it and log a warning.
      for f in $out/etc/ssl/certs/*; do
        if [ "$(head -c1 "$f" | od -A n -t x1 | tr -d ' \n')" = "30" ]; then
          openssl x509 -inform DER -outform PEM -in "$f" -out "$f.new"
          mv "$f.new" "$f"
        fi
      done

      runHook postInstall
    '';

    meta = commonMeta // {
      description = "CA certificates for Costa Rica's Firma Digital";
      longDescription = ''
        Certificate Authority certificates required by Costa Rica's
        Firma Digital (https://www.soportefirmadigital.com).
        Add these to security.pki.certificateFiles in your NixOS
        configuration to trust them system-wide.
      '';
    };
  };

  # ── PKCS#11 modules ───────────────────────────────────────────────────

  pkcs11 = stdenv.mkDerivation {
    pname = "firma-digital-cr-pkcs11";
    inherit version;
    src = zipArchive;
    nativeBuildInputs = [
      unzip
      autoPatchelfHook
    ];
    buildInputs = [
      pcsclite
      stdenv.cc.cc.lib
    ];

    unpackPhase = ''
      runHook preUnpack
      mkdir -p lib
      unzip -o -j $src '${pkcs11Dir}/*.so' -d lib
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp lib/libASEP11.so $out/lib/
      cp lib/libaseLaserP11.so $out/lib/
      runHook postInstall
    '';

    meta = commonMeta // {
      description = "ASE PKCS#11 modules for Costa Rica's Firma Digital";
      longDescription = ''
        PKCS#11 shared libraries (libASEP11.so and libaseLaserP11.so)
        for accessing Costa Rican digital signature smart cards
        from applications such as Firefox and Chrome.

        To use, configure your application's PKCS#11 security device
        to point to $out/lib/libASEP11.so or $out/lib/libaseLaserP11.so.
      '';
    };
  };

  # ── Idopte (unwrapped) ────────────────────────────────────────────────

  # The bundled .so files find each other via $ORIGIN RUNPATH. External
  # deps (webkit2gtk, openssl, glib, etc.) are provided by the FHS
  # wrappers below via targetPkgs.

  idopte-unwrapped = stdenv.mkDerivation {
    pname = "firma-digital-cr-idopte-unwrapped";
    inherit version;
    src = idopteExtracted;

    nativeBuildInputs = [
      patchelf
      makeWrapper
      python3
    ];
    buildInputs = [ ];

    dontAutoPatchelf = true;
    # The automatic patchelf setup-hook runs "patchelf --shrink-rpath"
    # on every ELF and strips RUNPATH entries it can't resolve inside
    # the build sandbox — which silently drops /usr/lib64 (it only
    # exists at runtime, inside the FHS wrapper). Skip it.
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/SCMiddleware
      mkdir -p $out/share/SCMiddleware/locale

      cp usr/lib/SCMiddleware/* $out/lib/SCMiddleware/
      cp usr/share/SCMiddleware/* $out/share/SCMiddleware/

      # crypto_common.py hardcodes /usr/share/SCMiddleware/tokmgr.bin,
      # which doesn't exist on NixOS. Make it resolve tokmgr.bin next
      # to itself instead, since both files always ship together.
      python3 - <<'PYEOF'
import os, pathlib
p = pathlib.Path(os.environ["out"]) / "share/SCMiddleware/crypto_common.py"
text = p.read_text()
old = (
    "\t\tif os.path.exists('/usr/lib/SCMiddleware') :\n"
    "\t\t\tarchive = zipfile.ZipFile(\"/usr/share/SCMiddleware/tokmgr.bin\", 'r')\n"
    "\t\telse:\n"
    "\t\t\tarchive = zipfile.ZipFile(\"/usr/share/in_p11/tokmgr.bin\", 'r')\n"
)
new = (
    "\t\tarchive = zipfile.ZipFile(os.path.join("
    "os.path.dirname(os.path.abspath(__file__)), \"tokmgr.bin\"), 'r')\n"
)
assert old in text, "crypto_common.py pattern not found -- upstream file changed?"
text = text.replace(old, new)

# nautilus-python's embedded Python interpreter only gets pygobject3
# added to sys.path (see nixpkgs' nautilus-python fix-paths.patch) --
# third-party "requests" is never available there. Use stdlib urllib
# instead, removing the dependency entirely.
old2 = "import requests\n"
new2 = "import urllib.request, urllib.parse\n"
assert old2 in text, "crypto_common.py requests import not found -- upstream file changed?"
text = text.replace(old2, new2)

old3 = (
    '\t\t\t\tr = requests.get("http://127.0.0.1:" + str(port) + '
    '"/dyn/cryptoshell_InitFromExplorer", params = params, timeout = 2)\n'
)
new3 = (
    "\t\t\t\tquery = urllib.parse.urlencode(params, doseq=True)\n"
    '\t\t\t\turl = "http://127.0.0.1:" + str(port) + '
    '"/dyn/cryptoshell_InitFromExplorer?" + query\n'
    "\t\t\t\turllib.request.urlopen(url, timeout=2)\n"
)
assert old3 in text, "crypto_common.py send_request body not found -- upstream file changed?"
text = text.replace(old3, new3)

p.write_text(text)
PYEOF

      for elf in $out/lib/SCMiddleware/SCManager \
                 $out/lib/SCMiddleware/idocachesrv \
                 $out/lib/SCMiddleware/*.so; do
        patchelf --set-rpath '$ORIGIN:/usr/lib64' "$elf"
      done

      mkdir -p $out/bin
      makeWrapper $out/lib/SCMiddleware/SCManager $out/bin/SCManager
      makeWrapper $out/lib/SCMiddleware/idocachesrv $out/bin/idocachesrv

      runHook postInstall
    '';

    meta = commonMeta // {
      description = "Idopte smart card middleware (unwrapped) for Costa Rica's Firma Digital";
    };
  };

  # ── Nautilus (GNOME Files) extension ─────────────────────────────

  nautilus-extension = stdenv.mkDerivation {
    pname = "firma-digital-cr-nautilus-extension";
    inherit version;
    src = idopteExtracted;
    nativeBuildInputs = [ python3 ];
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/nautilus-python/extensions
      cp usr/share/nautilus-python/extensions/CryptoshellExtension.py \
        $out/share/nautilus-python/extensions/

      # The upstream script picks its module search path at runtime by
      # checking for /usr/lib/SCMiddleware, which never exists on
      # NixOS. Point it directly at idopte-unwrapped's share dir, where
      # crypto_common.py (its only import) actually lives.
      export SCMIDDLEWARE_SHARE="${idopte-unwrapped}/share/SCMiddleware"
      python3 - <<'PYEOF'
import os, pathlib
p = pathlib.Path(os.environ["out"]) / "share/nautilus-python/extensions/CryptoshellExtension.py"
text = p.read_text()
old = (
    "if os.path.exists('/usr/lib/SCMiddleware') :\n"
    "\tsys.path.append('/usr/share/SCMiddleware')\n"
    "else :\n"
    "\tsys.path.append('/usr/share/in_p11')\n"
)
new = "sys.path.append(%r)\n" % os.environ["SCMIDDLEWARE_SHARE"]
assert old in text, "CryptoshellExtension.py pattern not found -- upstream file changed?"
p.write_text(text.replace(old, new))
PYEOF

      runHook postInstall
    '';

    meta = commonMeta // {
      description = "Nautilus (GNOME Files) right-click extension for Costa Rica's Firma Digital";
      longDescription = ''
        Adds "Sign", "Encrypt", "Sign+Encrypt" and "Open" context menu
        items in Nautilus (GNOME Files), talking to a running
        SCManager instance over its local HTTP API.

        Uses only the Python standard library (patched away from the
        upstream "requests" dependency, which nautilus-python's
        embedded interpreter never has on sys.path — see nixpkgs'
        nautilus-python fix-paths.patch, which only injects pygobject3).
        Requires zenity and pidof (procps) on PATH for error dialogs
        and process lookup.

        To enable, add "$out/share" to XDG_DATA_DIRS, or symlink
        $out/share/nautilus-python/extensions/CryptoshellExtension.py
        into ~/.local/share/nautilus-python/extensions/.
      '';
    };
  };

  # ── Idopte SCManager (FHS-wrapped) ────────────────────────────────────

  # ponytail: SCManager and idocachesrv hardcode /usr/share/SCMiddleware
  # and /usr/lib/SCMiddleware paths, so plain autoPatchelf isn't enough —
  # an FHS-style rootfs is needed. RUNPATH is $ORIGIN:/usr/lib64 so the
  # DEB's own bundled libcrypto.so.3/libssl.so.3 (Ubuntu 24.04 ABI) win
  # over nixpkgs' newer openssl in /usr/lib64, which is only a fallback
  # for libs the DEB doesn't ship (libxml2, webkit2gtk, glib, etc.).

  idopte = buildFHSEnv {
    name = "SCManager";
    targetPkgs = pkgs: [
      idopte-unwrapped
      pcsclite
      openssl_3_6
      webkitgtk_4_1
      gtk3
      glib
      libnotify
      libappindicator-gtk3
      libxml2-compat
      fontconfig
      freetype
      libpng
      bzip2
      expat
      brotli
      zlib
      zenity
      libx11
      libxext
      libxrender
      libxtst
      libxi
    ];
    runScript = "SCManager";
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/SCManager.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=SCManager
      Comment=Idopte smart card manager for Costa Rica's Firma Digital
      Exec=$out/bin/SCManager
      Icon=${idopte-unwrapped}/share/SCMiddleware/application.png
      Terminal=false
      Categories=Network;Security;
      EOF
    '';
    meta = commonMeta // {
      description = "Idopte smart card middleware (SCManager GUI) for Costa Rica's Firma Digital";
      longDescription = ''
        SCManager is the graphical smart card management application
        from Idopte, part of Costa Rica's Firma Digital ecosystem.

        It provides an interface to manage certificates and keys
        stored on cryptographic tokens and smart cards.
      '';
    };
  };

  # ── Idopte cache server (FHS-wrapped) ─────────────────────────────────

  idocachesrv = buildFHSEnv {
    name = "idocachesrv";
    targetPkgs = pkgs: [
      idopte-unwrapped
      pcsclite
      openssl_3_6
      libxml2-compat
      fontconfig
      freetype
      libpng
      bzip2
      expat
      brotli
      zlib
    ];
    runScript = "idocachesrv";
    meta = commonMeta // {
      description = "Idopte smart card cache daemon for Costa Rica's Firma Digital";
      longDescription = ''
        idocachesrv is the smart card caching daemon from Idopte, part
        of Costa Rica's Firma Digital ecosystem.

        It provides mechanisms to share smart card and token data
        among processes. This service must be running for PKCS#11
        operations with Costa Rican digital certificates.
      '';
    };
  };

  # ── Agente GAUDI (unwrapped) ──────────────────────────────────────────

  agente-gaudi-unwrapped = stdenv.mkDerivation {
    pname = "firma-digital-cr-agente-gaudi-unwrapped";
    inherit version;
    src = gaudiExtracted;

    dontAutoPatchelf = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/opt/Agente-GAUDI
      cp -r opt/Agente-GAUDI/* $out/opt/Agente-GAUDI/
      runHook postInstall
    '';
  };

  # ── Agente GAUDI (FHS-wrapped) ────────────────────────────────────────

  agente-gaudi = buildFHSEnv {
    name = "agente-gaudi";
    targetPkgs = pkgs: [
      agente-gaudi-unwrapped
      # The bundled signing client (bccr-firma-fva-clienteMultiplataforma.jar,
      # extracted at runtime into ~/.cache/Agente-GAUDI/) hardcodes
      # /usr/lib/SCMiddleware/libidop11.so as its PKCS#11 module path.
      # idopte-unwrapped ships that file under lib/SCMiddleware/, which
      # buildFHSEnv merges into /usr/lib/ here -- same trick idopte's own
      # buildFHSEnv already relies on. pcsclite/openssl_3_6 are libidop11.so's
      # own runtime deps, resolved via its $ORIGIN:/usr/lib64 RUNPATH.
      idopte-unwrapped
      pcsclite
      openssl_3_6
      libx11
      libxext
      libxrender
      libxtst
      libxi
      pkgs.libGL
      pkgs.gtk3
      pkgs.glib
      pkgs.pango
      pkgs.cairo
      pkgs.gdk-pixbuf
      pkgs.fontconfig
      pkgs.freetype
      pkgs.alsa-lib
      pkgs.zlib
    ];
    runScript = "bash -c 'cd ${agente-gaudi-unwrapped}/opt/Agente-GAUDI/bin && exec ./Agente-GAUDI'";
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/agente-gaudi.desktop <<EOF
      [Desktop Entry]
      Version=29.0
      Name=Agente-GAUDI
      Comment=Agente-GAUDI del Banco Central de Costa Rica
      GenericName=Agente-GAUDI
      Exec=$out/bin/agente-gaudi
      Icon=${agente-gaudi-unwrapped}/opt/Agente-GAUDI/lib/Agente-GAUDI.png
      Terminal=false
      Type=Application
      Categories=Network;Application;
      StartupNotify=true
      EOF
    '';
    meta = commonMeta // {
      description = "Agente GAUDI from BCCR for Costa Rica's Firma Digital";
      longDescription = ''
        Agente GAUDI is the digital signature agent from Banco Central
        de Costa Rica (BCCR), part of the Firma Digital ecosystem.

        It provides a system tray application that handles digital
        signature requests from web applications using Costa Rican
        digital certificates.
      '';
      mainProgram = "agente-gaudi";
    };
  };
}
