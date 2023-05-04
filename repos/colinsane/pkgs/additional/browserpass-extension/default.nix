{ stdenv
, fetchFromGitHub
, fetchFromGitea
, gnused
, jq
, mkYarnModules
, zip
}:

let
  pname = "browserpass-extension";
  version = "3.7.2-20221121";
  # src = fetchFromGitHub {
  #   owner = "browserpass";
  #   repo = "browserpass-extension";
  #   # rev = version;
  #   rev = "21f3431d09e1d7ffd33e0b9fc5d2965b7bd93a1a";
  #   sha256 = "sha256-XIgbaQSAXx7L1e/9rzN7oBQy9U3HWJHOX2auuvgdvbc=";
  # };
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "browserpass-extension";
    # hack in sops support
    rev = "e3bf558ff63d002d3c15f2ce966071f04fada306";
    sha256 = "sha256-dSRZ2ToEOPhzHNvlG8qdewa7689gT8cNB7nXkN3/Avo=";
  };
  browserpass-extension-yarn-modules = mkYarnModules {
    inherit pname version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    # yarnNix is auto-generated. to update: leave unset, then query the package deps and copy it out of the store.
    yarnNix = ./yarn.nix;
    # the following also works, but because it's IFD it's not allowed by some users, like NUR.
    # packageJSON = "${src}/src/package.json";
    # yarnLock = "${src}/src/yarn.lock";
  };
  extid = "browserpass@maximbaz.com";
in stdenv.mkDerivation {
  inherit pname version src;

  patchPhase = ''
    # dependencies are built separately: skip the yarn install
    ${gnused}/bin/sed -i /yarn\ install/d src/Makefile
  '';

  preBuild = ''
    ln -s ${browserpass-extension-yarn-modules}/node_modules src/node_modules
  '';

  installPhase = ''
    BASE=$out/share/mozilla/extensions/\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}
    mkdir -p $BASE

    pushd firefox

    # firefox requires addons to have an id field when sideloading:
    # - <https://extensionworkshop.com/documentation/publish/distribute-sideloading/>
    cat manifest.json \
      | ${jq}/bin/jq '. + { applications: {gecko: {id: "${extid}" }}, browser_specific_settings: {gecko: {id: "${extid}"}} }' \
      > manifest.patched.json
    mv manifest{.patched,}.json

    ${zip}/bin/zip -r $BASE/browserpass@maximbaz.com.xpi ./*

    popd
  '';

  passthru = {
    inherit extid;
  };
}
