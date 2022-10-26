{ lib
, fetchFromGitHub
, mkYarnPackage
, fetchYarnDeps
, buildGoModule
, makeWrapper
, v2ray
, v2ray-geoip
, v2ray-domain-list-community
, symlinkJoin
}:
let
  pname = "v2raya";
  version = "unstable-2022-10-04";
  src = fetchFromGitHub {
    owner = "v2rayA";
    repo = "v2rayA";
    rev = "11aa2b0a982989983fd086510f8fea864ed92deb";
    sha256 = "sha256-da5fpbNQBRvXNUe0CRbW5CjLfxYRgLUX+nlsp1JnnmA=";
  };
  web = mkYarnPackage {
    inherit pname version;
    src = "${src}/gui";

    postPatch = ''
      substituteInPlace gui/yarn.lock \
        --replace "sha512-DJ8vmYyRdq8oX2l1/sGNmJjAD1KGaVvhtNUtHPJLbXpe5GoZut5UFQLM4FoFK9eyoZA1Y7chJEmEkNfs9Bdjrw==" "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670" \
        --replace "sha512-P1BJAEAW3E2DJUlkgq4tOL3RyMunoWXqbSCygWo5ZIWTjUgN1YnaXWW4VWl/oc8vs/XoYibEGBKP0uZyF4AHig=="  "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670" \
        --replace "sha512-zWt4SDDv1S9WRBNxLFxFRHxdD9tvH8f5/kg5/IaLFdnSNXsDY4eL3Q3XXN+VxUnWIhyVFDwcsmAprvwXoM/ClA==" "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670" \
        --replace "sha512-O3MmRAk6ZuAKa9CHgg0Pr0+lUOqoMLpc9AS4R8ano2auvsg7IE8syF3Xh/NPr26TWklxYcqoEEFdzLLs1fV9PQ==" "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670" \
        --replace "sha512-Gj7cI7z+98M282Tqmp2K5EIsoouUEzbBJhQQzDE3jSIRk6r9gsz0oUokqIUR4u1R3dMHo0pDHM7sNOHyhulypw==" "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670" \
        --replace "sha512-Ft7YH3lEVRQ6ls8k4Ff1oB4jN6oy/XmU6tQISKdhfh+1mR+viZFphS6WL0IrtDOzvefmJg5a0s7ZQoRXwqTEFg==" "60678ac22711bb7af8adc2efc449443885b81ee1463fd160e22dc99249e997bad3cdb7b60284026f4a3f0267ace874fa0876e09d4f15052a75859ef672fd6670"
    '';

    offlineCache = fetchYarnDeps {
      yarnLock = src + "/gui/yarn.lock";
      sha256 = "";
    };
    packageJSON = ./package.json;

    # https://github.com/webpack/webpack/issues/14532
    buildPhase = ''
      export NODE_OPTIONS=--openssl-legacy-provider
      ln -s $src/postcss.config.js postcss.config.js
      OUTPUT_DIR=$out yarn --offline build
    '';
    distPhase = "true";
    dontInstall = true;
    dontFixup = true;
  };
in
buildGoModule {
  inherit pname version;
  src = "${src}/service";
  vendorSha256 = "sha256-RqpXfZH0OvoG0vU17oAHn1dGLQunlUJEW89xuCSGEoE=";
  subPackages = [ "." ];
  nativeBuildInputs = [ makeWrapper ];
  preBuild = ''
    cp -a ${web} server/router/web
  '';
  postInstall = ''
    wrapProgram $out/bin/v2rayA \
      --prefix PATH ":" "${lib.makeBinPath [ v2ray ]}" \
      --prefix XDG_DATA_DIRS ":" ${symlinkJoin {
        name = "assets";
        paths = [ v2ray-geoip v2ray-domain-list-community ];
      }}/share
  '';
  meta = with lib; {
    description = "A Linux web GUI client of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel";
    homepage = "https://github.com/v2rayA/v2rayA";
    mainProgram = "v2rayA";
    license = licenses.agpl3Only;
    # maintainers = with lib.maintainers; [ shanoaice ];
  };
}
