{ mylibs, runCommand, buildBowerComponents, pythonPackages, libsass, python, fetchurl, jq, yarn, nodejs }:
let
  buildslist_src = mylibs.fetchedGit ./buildslist.json;
  packagejson = runCommand "package.json" { buildInputs = [ jq ]; } ''
    cat ${buildslist_src.src}/package.json | jq -r '.version = "${pythonPackages.buildbot-pkg.version}"' > $out
    '';
  buildslist_yarn = mylibs.yarn2nixPackage.mkYarnModules rec {
    name = "buildslist-yarn-modules";
    pname = name;
    inherit (pythonPackages.buildbot-pkg) version;
    packageJSON = packagejson;
    yarnLock = "${buildslist_src.src}/yarn.lock";
    yarnNix = ./yarn-packages.nix;
    pkgConfig = {
      all = { buildInputs = [ mylibs.yarn2nixPackage.src ]; };
      node-sass = {
        buildInputs = [ libsass python ];
        postInstall = let
          nodeHeaders = fetchurl {
            url = "https://nodejs.org/download/release/v${nodejs.version}/node-v${nodejs.version}-headers.tar.gz";
            sha256 = "16f20ya3ys6w5w6y6l4536f7jrgk4gz46bf71w1r1xxb26a54m32";
          };
        in
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
in
pythonPackages.buildPythonPackage rec {
  pname = "buildbot-buildslist";
  inherit (pythonPackages.buildbot-pkg) version;

  preConfigure = ''
    export HOME=$PWD
    ln -s ${buildslist_yarn}/node_modules .
    cp -a ${buildslist_bower}/bower_components ./libs
    chmod -R u+w libs
    '';
  propagatedBuildInputs = with pythonPackages; [
    (klein.overridePythonAttrs(old: { checkPhase = ""; }))
    buildbot-pkg
  ];
  nativeBuildInputs = [ yarn nodejs ];
  buildInputs = [ buildslist_yarn buildslist_bower ];

  doCheck = false;
  src = buildslist_src.src;
}
