{ varDir ? "/var/lib/etherpad-lite" # if you override this change the StateDirectory in service file too!
, stdenv, callPackage, mylibs, fetchurl }:
let
  jquery = fetchurl {
    url = https://code.jquery.com/jquery-1.9.1.js;
    sha256 = "0h4dk67yc9d0kadqxb6b33585f3x3559p6qmp70l00qwq030vn3v";
  };
  withModules = modules: package.overrideAttrs(old: {
    installPhase = let
      modInst = n:
      let n' = n.override {
        postInstall = ''
          if [ ! -f $out/lib/node_modules/${n.moduleName}/.ep_initialized ]; then
            ln -s ${varDir}/ep_initialized/${n.moduleName} $out/lib/node_modules/${n.moduleName}/.ep_initialized
          fi
        '';
      };
        in "cp -a ${n'}/lib/node_modules/${n.moduleName} $out/node_modules";
    in old.installPhase + builtins.concatStringsSep "\n" (map modInst modules);
    passthru = old.passthru // {
      inherit modules;
      withModules = moreModules: old.withModules (moreModules ++ modules);
    };
  });
  # built using node2nix -l package-lock.json
  # and changing "./." to "src"
  node-environment = (callPackage ./node-packages.nix {
    nodeEnv = callPackage mylibs.nodeEnv {};
    src = stdenv.mkDerivation (mylibs.fetchedGithub ./etherpad-lite.json // rec {
      patches = [ ./libreoffice_patch.diff ];
      buildPhase = ''
        touch src/.ep_initialized
        cp -v src/static/custom/js.template src/static/custom/index.js
        cp -v src/static/custom/js.template src/static/custom/pad.js
        cp -v src/static/custom/js.template src/static/custom/timeslider.js
        cp -v src/static/custom/css.template src/static/custom/index.css
        cp -v src/static/custom/css.template src/static/custom/pad.css
        cp -v src/static/custom/css.template src/static/custom/timeslider.css
        '';
      installPhase = ''
        cp -a src/ $out
        '';
    });
  }).package;
  package = stdenv.mkDerivation rec {
    name = (mylibs.fetchedGithub ./etherpad-lite.json).name;
    src = node-environment;
    installPhase = ''
      mkdir -p $out
      mkdir $out/node_modules
      cp -a lib/node_modules/ep_etherpad-lite $out/src
      chmod u+w $out/src/static/js/
      cp ${jquery} $out/src/static/js/jquery.js
      ln -s ../src $out/node_modules/ep_etherpad-lite
      '';
    passthru = {
      modules = [];
      inherit varDir withModules;
    };
  };
in package
