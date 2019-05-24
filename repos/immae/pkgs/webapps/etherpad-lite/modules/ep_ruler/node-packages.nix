{stdenv, nodeEnv, fetchurl, fetchgit, globalBuildInputs ? []}:

let
  sources = {};
in
{
  ep_ruler = nodeEnv.buildNodePackage {
    name = "ep_ruler";
    packageName = "ep_ruler";
    version = "0.0.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/ep_ruler/-/ep_ruler-0.0.2.tgz";
      sha1 = "5af10dfe0b5f33459566ce649cc483c680ed7811";
    };
    preRebuild = ''
      sed -i -e 's/"dependencies"/"peerDependencies"/' package.json
      '';
    buildInputs = globalBuildInputs;
    meta = {
      description = "Adds a ruler to Etherpad lite";
      homepage = https://github.com/iquidus/ep_ruler;
    };
    production = true;
    bypassCache = false;
  };
}

