{
  lib,
  stdenv,
  pins,
  buildGoModule,
  buildNpmPackage,
}:
let
  pname = "broadcast-box";
  version = "unstable-2024-07-01";
  src = pins.broadcast-box.outPath;
  meta = with lib; {
    description = "WebRTC broadcast server";
    homepage = "https://github.com/Glimesh/broadcast-box";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
  };

  web = buildNpmPackage {
    pname = "${pname}-web";
    inherit version;
    src = "${src}/web";
    npmDepsHash = "sha256-BusrGTcY6P7xpwgoB1ScFUFg3lMDEmX5TatYZBULGNc=";
    preBuild = ''
      cp "${src}/.env.production" ../
    '';
    installPhase = ''
      runHook preInstall

      cp -r build $out

      runHook postInstall
    '';

    inherit meta;
  };
in
buildGoModule rec {
  inherit pname version src;

  vendorHash = "sha256-Z0gqZA/HUiZHFHF93sVWo2aDyUyJBPHCwqciJxyRCZM=";
  proxyVendor = true;

  postPatch = ''
    substituteInPlace main.go \
      --replace-fail './web/build' '${placeholder "out"}/share/broadcast-box'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/broadcast-box
    cp -r ${web}/* $out/share/broadcast-box

    cp -r "$GOPATH/bin" $out

    runHook postInstall
  '';

  inherit meta;
}
