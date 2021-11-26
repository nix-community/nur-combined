{ pkgs, lib, stdenv, nodejs, ffmpeg, glibc }:

let
  composition = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  # Do not "npm install" this package
  nodeVdhcoapp = (
    lib.findSingle
      (drv: drv ? packageName && drv.packageName == "vdhcoapp")
      (throw "no 'vdhcoapp' package found in nodePackages")
      (throw "multiple 'vdhcoapp' packages found in nodePackages")
      (lib.attrValues composition)
  ).override (drv: { dontNpmInstall = true; });

  appName = "net.downloadhelper.coapp";
  commonManifest = {
    name = appName;
    description = "Video DownloadHelper companion app";
    path = "DIR/${appName}";
    type = "stdio";
  };
  firefoxManifest = pkgs.writeText "firefoxManifest" (
    builtins.toJSON (lib.recursiveUpdate
      commonManifest
      {
        allowed_extensions = [
          "weh-native-test@downloadhelper.net"
          "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}"
        ];
      }
    ));
  chromeManifest = pkgs.writeText "chromeManifest" (
    builtins.toJSON (lib.recursiveUpdate
      commonManifest
      {
        allowed_origins = [
          "chrome-extension://lmjnegcaeklhafolokijcfjliaokphfk/"
        ];
      }
    ));

in
stdenv.mkDerivation rec {
  pname = "vdhcoapp";
  inherit (nodeVdhcoapp) version src;

  buildInputs = [
    glibc
    nodejs
    nodeVdhcoapp
  ];

  patches = [
    ./0001-Make-the-app-runnable-without-pkg.patch
    # Allows setting Brave and Vivaldi through user installation
    ./0001-Adding-brave-and-vivaldi-user-installation.patch
  ];

  postPatch = ''
    sed -i 's#^\(const binaryDir =\).*$#\1 "${ffmpeg}/bin";#' app/converter.js
    chmod -x *.js *.json app/*.js assets/*
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/vdhcoapp
    cp -pr -t $out/share/vdhcoapp/ \
      app \
      assets \
      config.json \
      index.js \
      package.json \
      ${nodeVdhcoapp}/lib/node_modules/vdhcoapp/node_modules

    cat << EOF > $out/share/vdhcoapp/${appName}
    #!/bin/sh
    NODE_PATH=$out/share/vdhcoapp/node_modules exec ${nodejs}/bin/node $out/share/vdhcoapp/index.js "\$@"
    EOF
    chmod +x $out/share/vdhcoapp/${appName}

    installManifest() {
      install -d $out$2
      cp $1 $out$2/${appName}.json
      substituteInPlace $out$2/${appName}.json --replace DIR $out/share/vdhcoapp
    }
    installManifest ${chromeManifest}  /etc/opt/chrome/native-messaging-hosts
    installManifest ${chromeManifest}  /etc/chromium/native-messaging-hosts
    installManifest ${firefoxManifest} /lib/mozilla/native-messaging-hosts
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Companion application for the Video DownloadHelper browser add-on";
    homepage = "https://www.downloadhelper.net/";
    license = licenses.gpl2;
    platforms = nodejs.meta.platforms;
  };
}
