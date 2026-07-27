{ lib, buildFHSEnv, runCommandNoCCLocal, writeScriptBin, fetchurl, fakeroot
, procps }:
let
  src = fetchurl {
    url = "file:///anyconnect-linux64-4.10.01075-core-vpn-webdeploy-k9.sh";
    sha256 = "sha256-S94WjcEFldF/PGwEjQMasqtiybcfrjF5z8Ns2v1WPRw=";
  };

  installScript = writeScriptBin "anyconnect-install-script" ''
    install -d $out/usr/share/icons/hicolor/{48x48,64x64,96x96,128x128,256x256,512x512}/apps
    install -d $out/usr/share/applications
    install -d $out/usr/share/desktop-directories
    install -d $out/etc/systemd/system
    install -d $out/opt/cisco

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cisco/anyconnect/lib

    cd /vpn
    echo y | ./vpn_install.sh

    cp -r /opt/cisco/anyconnect $out/opt/cisco
  '';

  installer = buildFHSEnv {
    name = "anyconnect-installer";

    targetPkgs = pkgs: with pkgs; [ procps installScript libxml2 glib ];

    extraBuildCommands = ''
      ${fakeroot}/bin/fakeroot -- bash ${src} || true

      mkdir -p $out
      mv /tmp/vpn $out

      cd $out/vpn
      patch -p1 < ${./nix.patch}
      substituteInPlace vpn_install.sh \
        --replace '-o root' '-o $(whoami)' \
        --replace '/usr/share' '$out/usr/share' \
        --replace '/etc/xdg' '$out/etc/xdg' \
        --replace '/etc/systemd/system' '$out/etc/systemd/system' \
        --replace '`ls -l /proc/1/exe`' 'systemd' \
        --replace '/tmp/''${LOGFNAME}' '/build/''${LOGFNAME}'
    '';

    runScript = "anyconnect-install-script";
  };

  bin = runCommandNoCCLocal "anyconnect-bin" {
    passthru = { inherit installer; };
  } ''
    ${installer}/bin/anyconnect-installer
  '';

  createAnyconnectScript = args: buildFHSEnv {
      inherit (args) name runScript;

      targetPkgs = pkgs:
        with pkgs; [
          bin
          libxml2
          gtk2
          gtk3
          atk
          zlib
          glib
          pango
          gdk-pixbuf
          cairo
          freetype
          fontconfig
          networkmanager
          nss
          nspr
          firefox
        ];

      extraOutputsToInstall = [ "opt" ];

      passthru = { inherit bin; };
    };
    createAnyconnectExe = name: createAnyconnectScript {
      inherit name;
      runScript = "/opt/cisco/anyconnect/bin/${name}";
    };
in {
  vpnagentd = createAnyconnectExe "vpnagentd";
  vpnui = createAnyconnectExe "vpnui";
  acinstallhelper = createAnyconnectExe "acinstallhelper";
  inherit bin;
}
