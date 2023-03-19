# $out/bin/redis-commander.js

# default config
# $out/config/default.json

# custom config
# $out/config/local.json

/* $out/lib/util.js

function getConfigPath (configFile) {
  const c = require('config');
  const configPath = c.util.getEnv('NODE_CONFIG_DIR');
  if (configFile === 'local') {
    return path.join(configPath, 'local.json');
  }
  else {  // connections
    return path.join(configPath, 'local-' + c.util.getEnv('NODE_ENV') + '.json');
  }
}
*/

{ pkgs, fetchFromGitHub, callPackage, python3, npmlock2nix }:

npmlock2nix.v2.build {
  src = fetchFromGitHub {
    # https://github.com/joeferner/redis-commander
    owner = "joeferner";
    repo = "redis-commander";
    rev = "4bb60a06660e4c55f0e9c46f1d3a9ce6b1bee6ef";
    sha256 = "sha256-XBIhKRwGtHaR7+4m81+6SAhWf9AusTG/I1ZU4uVMbFE=";
  };
  installPhase = ''
    cp -r . $out
    mv -v $out/bin/redis-commander.js $out/bin/redis-commander
  '';
  #node_modules_mode = "copy";
  node_modules_attrs = {
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
    buildInputs = [
      python3 # for node-gyp
    ];
  };
}

# fixme? EPERM: operation not permitted, rename
