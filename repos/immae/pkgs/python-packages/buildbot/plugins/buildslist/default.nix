{ mylibs, stdenv, runCommand, writeScriptBin, buildBowerComponents, pythonPackages, libsass, python, fetchurl, jq, yarn, nodejs, yarn2nix-moretea }:
let
  buildslist_src = mylibs.fetchedGit ./buildslist.json;
  packagejson = runCommand "package.json" { buildInputs = [ jq ]; } ''
    cat ${buildslist_src.src}/package.json | jq -r '.version = "${pythonPackages.buildbot-pkg.version}"|.license= "MIT"' > $out
    '';
  nodeHeaders = fetchurl {
    url = "https://nodejs.org/download/release/v${nodejs.version}/node-v${nodejs.version}-headers.tar.gz";
    sha256 = "1df3yhlwlvai0m9kvjyknjg11hnw0kj0rnhyzbwvsfjnmr6z8r76";
  };
  buildslist_yarn = yarn2nix-moretea.mkYarnModules rec {
    name = "buildslist-yarn-modules";
    pname = name;
    inherit (pythonPackages.buildbot-pkg) version;
    packageJSON = packagejson;
    yarnLock = "${buildslist_src.src}/yarn.lock";
    yarnNix = ./yarn-packages.nix;
    pkgConfig = {
      node-sass = {
        buildInputs = [ libsass python ];
        postInstall =
          ''
            node scripts/build.js --tarball=${nodeHeaders}
          '';
      };
    };
  };
  buildslist_bower = buildBowerComponents {
    name = "buildslist";
    generated = ./bower.nix;
    src = "${buildslist_src.src}/guanlecoja/";
  };
  # the buildbot-pkg calls yarn and screws up everything...
  fakeYarn = writeScriptBin "yarn" ''
    #!${stdenv.shell}
    if [ "$1" = "--version" ]; then
      echo "1.17"
    fi
    '';
in
pythonPackages.buildPythonPackage rec {
  pname = "buildbot-buildslist";
  inherit (pythonPackages.buildbot-pkg) version;

  preConfigure = ''
    export HOME=$PWD
    ln -s ${buildslist_yarn}/node_modules .
    cp -a ${buildslist_bower}/bower_components ./libs
    PATH=${buildslist_yarn}/node_modules/.bin:$PATH
    chmod -R u+w libs
    '';
  propagatedBuildInputs = with pythonPackages; [
    (klein.overridePythonAttrs(old: { checkPhase = ""; }))
    buildbot-pkg
  ];
  nativeBuildInputs = [ fakeYarn nodejs ];
  buildInputs = [ buildslist_yarn buildslist_bower ];

  doCheck = false;
  src = buildslist_src.src;
}
