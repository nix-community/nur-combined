{ pkgs, lib, stdenv, nodejs-12_x, ffmpeg-full }:

let

  # `npm install` warns about incompatibilities with more recent nodejs versions:
  #     chokidar@2.1.8: Chokidar 2 will break on node v14+. Upgrade to chokidar 3 with 15x less dependencies.
  #     fsevents@1.2.13: fsevents 1 will break on node v14+ and could be using insecure binaries. Upgrade to fsevents 2.
  #
  nodejs = nodejs-12_x;

  # `ffmpeg-full` is needed, because the smaller `ffmpeg` package does not
  # contain `ffplay`.
  #
  # `nix flake check` complains that `intel-media-sdk` (== `libmfx`) is not
  # supported on `i686-linux`; disable it explicitly for anything other than
  # `x86_64-linux`.
  #
  ffmpeg =
    if stdenv.isLinux && stdenv.isx86_64 then
      ffmpeg-full
    else
      ffmpeg-full.override { libmfx = null; };

  privateNodePackages = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  nodeVdhcoapp = (
    lib.findSingle
      (drv: drv ? packageName && drv.packageName == "vdhcoapp")
      (throw "no 'vdhcoapp' package found in privateNodePackages")
      (throw "multiple 'vdhcoapp' packages found in privateNodePackages")
      (lib.attrValues privateNodePackages)
  ).override (drv: { dontNpmInstall = true; });

  # Build native manifests like `app/native-autoinstall.js` does.  The data for
  # these manifests was copied from `config.json` and might need to be updated
  # if this file is changed in a new upstream release.
  #
  # Note that using the same manifest for Firefox and Chrome is not possible,
  # because at least Firefox 88 rejects the manifest with the Chrome-specific
  # `allowed_origins` key.
  #
  appName = "net.downloadhelper.coapp";
  commonManifest = {
    name = appName;
    description = "Video DownloadHelper companion app";
    path = "DIR/${appName}";
    type = "stdio";
  };
  firefoxManifest = commonManifest // {
    allowed_extensions = [
      "weh-native-test@downloadhelper.net"
      "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}"
    ];
  };
  chromeManifest = commonManifest // {
    allowed_origins = [
      "chrome-extension://lmjnegcaeklhafolokijcfjliaokphfk/"
    ];
  };

in
stdenv.mkDerivation rec {
  pname = "vdhcoapp";
  inherit (nodeVdhcoapp) version src;

  buildInputs = [
    nodejs
    nodeVdhcoapp
  ];

  patches = [
    ./0001-Make-the-app-runnable-without-pkg.patch
  ];

  postPatch = ''
    sed -i 's#^\(const binaryDir =\).*$#\1 "${ffmpeg}/bin";#' app/converter.js
    chmod -x *.js *.json app/*.js assets/*
  '';

  dontConfigure = true;
  dontBuild = true;

  chromeManifestJSON = builtins.toJSON chromeManifest;
  firefoxManifestJSON = builtins.toJSON firefoxManifest;
  passAsFile = [
    "chromeManifestJSON"
    "firefoxManifestJSON"
  ];

  installPhase = ''
    mkdir -p $out/share/vdhcoapp
    cp -pr -t $out/share/vdhcoapp/ app assets LICENSE.txt README.md config.json index.js package.json
    cp -pr -t $out/share/vdhcoapp/ ${nodeVdhcoapp}/lib/node_modules/vdhcoapp/node_modules

    echo "#! /bin/sh
    NODE_PATH=$out/share/vdhcoapp/node_modules exec ${nodejs}/bin/node $out/share/vdhcoapp/index.js \"\$@\"
    " >$out/share/vdhcoapp/${appName}
    chmod +x $out/share/vdhcoapp/${appName}

    installManifest() {
      install -d $out$2
      cp $1 $out$2/${appName}.json
      substituteInPlace $out$2/${appName}.json --replace DIR $out/share/vdhcoapp
    }
    installManifest $chromeManifestJSONPath  /etc/opt/chrome/native-messaging-hosts
    installManifest $chromeManifestJSONPath  /etc/chromium/native-messaging-hosts
    installManifest $firefoxManifestJSONPath /lib/mozilla/native-messaging-hosts
  '';

  passthru = {
    updateScript = ./update.sh;
  };

  meta = with lib; {
    homepage = "https://www.downloadhelper.net/";
    downloadPage = "https://github.com/mi-g/vdhcoapp/releases";
    description = ''
      Companion application for the Video DownloadHelper browser add-on.
    '';
    license = licenses.gpl2;
    platforms = nodejs.meta.platforms;
  };
}
