{ lib
, fetchFromGitHub
, mkYarnPackage
, buildGoModule
, makeWrapper
, xray
, v2ray-geoip
, v2ray-domain-list-community
, symlinkJoin
}:
let
  pname = "xrayA";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "iopq";
    repo = "xraya";
    rev = "54a3cb996ab9f4ae5cfaff9f2475f0db5bf95225";
    sha256 = "gdT0VFcNkSd0TH1VJPnbErdoCBp077rcNWOJkaxfhi4=";
  };

  web = mkYarnPackage {
    inherit pname version;
    src = "${src}/gui";
    yarnNix = ./yarn.nix;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    buildPhase = ''
      export NODE_OPTIONS=--openssl-legacy-provider
      ln -s $src/postcss.config.js postcss.config.js
      OUTPUT_DIR=$out yarn --offline build
    '';
    distPhase = "true";
    dontInstall = true;
    dontFixup = true;
  };

  assetsDir = symlinkJoin {
    name = "assets";
    paths = [ v2ray-geoip v2ray-domain-list-community ];
  };

in
buildGoModule {
  inherit pname version;

  src = "${src}/service";
  vendorSha256 = "sha256-Yz6+4ghiJf6a9TB4Sql5AY67dX0mLGhf6H4PVKGXSFE=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/v2rayA/v2rayA/conf.Version=${version}"
  ];

  subPackages = [ "." ];

  nativeBuildInputs = [ makeWrapper ];
  preBuild = ''
    cp -a ${web} server/router/web
  '';

  postInstall = ''
    install -Dm 444 ${src}/install/universal/v2raya.desktop -t $out/share/applications
    install -Dm 444 ${src}/install/universal/v2raya.png -t $out/share/icons/hicolor/512x512/apps
    substituteInPlace $out/share/applications/v2raya.desktop \
      --replace 'Icon=/usr/share/icons/hicolor/512x512/apps/v2raya.png' 'Icon=v2raya'

    wrapProgram $out/bin/xraya \
      --prefix PATH ":" "${lib.makeBinPath [ xray ]}" \
      --prefix XDG_DATA_DIRS ":" ${assetsDir}/share \
      --prefix ASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH ":" go1.20 
  '';

  meta = with lib; {
    description = "A Linux web GUI client of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel";
    homepage = "https://github.com/iopq/xraya";
    mainProgram = "xrayA";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ iopq ];
  };
}

