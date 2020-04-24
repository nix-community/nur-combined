{ varDir ? "/var/lib/grocy", stdenv, callPackage, composerEnv, fetchurl, mylibs, runCommand, git, which, jq, yarn2nix-moretea }:
let
  version = "2.6.1-1";
  packagesource = mylibs.fetchedGithub ./grocy.json;
  patchedPackages = stdenv.mkDerivation (packagesource // rec {
    buildInputs = [ jq ];
    patches = [ ./yarn.patch ];
    installPhase = ''
      mkdir $out
      cat package.json | jq -r '.version = "${version}"' > $out/package.json
      cp yarn.lock $out/
      '';
  });
  yarnModules = yarn2nix-moretea.mkYarnModules rec {
    name = "grocy-yarn";
    pname = name;
    version = version;
    packageJSON = "${patchedPackages}/package.json";
    yarnLock = "${patchedPackages}/yarn.lock";
    yarnNix = ./yarn-packages.nix;
    pkgConfig = {
      all = {
        buildInputs = [ git which ];
      };
    };
  };
  app = composerEnv.buildPackage (
    import ./php-packages.nix { inherit composerEnv fetchurl; } //
    packagesource //
    {
      noDev = true;
      buildInputs = [ yarnModules ];
      postInstall = ''
        rm -rf data
        ln -sf ${varDir}/data data
        ln -sf ${yarnModules}/node_modules public
      '';
      passthru = {
        inherit varDir yarnModules;
        webRoot = "${app}/public";
      };
    }
  );
in
  app
