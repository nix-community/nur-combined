{
  mkYarnPackage,
  fetchYarnDeps,
  source,
}:
mkYarnPackage rec {
  inherit (source) pname src;
  packageJSON = ./package.json;
  offlineCache = fetchYarnDeps {
    yarnLock = "${src}" + "/yarn.lock";
    hash = "sha256-1JEcBNCztsAwYgxzdBtWbquuuWnb2vL8hbzAlRBnHKc=";
  };
  version = "0-unstable-" + source.date;
  buildPhase = "yarn --offline build";
  installPhase = ''
    yarn --offline pack --filename main.tgz
    mkdir -p $out
    tar xzf main.tgz --strip-components=1 -C $out
  '';
  distPhase = "true";
}
