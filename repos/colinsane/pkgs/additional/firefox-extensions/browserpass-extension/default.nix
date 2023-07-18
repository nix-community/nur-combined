{ stdenv
, fetchFromGitHub
, fetchFromGitea
, gnused
, mkYarnModules
, zip
}:

let
  pname = "browserpass-extension";
  version = "3.7.2-2023-06-18";
  src = fetchFromGitHub {
    owner = "browserpass";
    repo = "browserpass-extension";
    # rev = version;
    rev = "858cc821d20df9102b8040b78d79893d4b7af352";
    hash = "sha256-m1JmwAKsYyfKLYbtfBn3IKT48Af5Az34BXmJQ1tYaz4=";
  };
  # src = fetchFromGitea {
  #   domain = "git.uninsane.org";
  #   owner = "colin";
  #   repo = "browserpass-extension";
  #   # hack in sops support
  #   rev = "e3bf558ff63d002d3c15f2ce966071f04fada306";
  #   sha256 = "sha256-dSRZ2ToEOPhzHNvlG8qdewa7689gT8cNB7nXkN3/Avo=";
  # };
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
in stdenv.mkDerivation {
  inherit pname version src;

  postPatch = ''
    # dependencies are built separately: skip the yarn install
    ${gnused}/bin/sed -i /yarn\ install/d src/Makefile
  '';

  preBuild = ''
    ln -s ${browserpass-extension-yarn-modules}/node_modules src/node_modules
  '';

  installPhase = ''
    pushd firefox
    ${zip}/bin/zip -r $out ./*
    popd
  '';

  passthru = {
    extid = "browserpass@maximbaz.com";
  };
}
