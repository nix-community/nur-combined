{ nodeEnv, callPackage, fetchurl }: let
  nodePackages = callPackage ./node-packages.nix {
    inherit nodeEnv;
  };
in nodeEnv.buildNodePackage rec {
  inherit (nodePackages.args) name version dependencies packageName meta;
  reconstructLock = false;
  src = fetchurl {
    url = "https://registry.npmjs.org/${packageName}/-/${packageName}-${version}.tgz";
    sha512 = "0v6qd4syh5vhgk9xmxrw9kgrj297vqp3137jf58jm9brwijb8qc8dnvzj3d60npdgk28qrjpi9cqikvcymwa7nl61gvbx5cdqc6ag64";
  };
  dontNpmInstall = true;

  postInstall = ''
    install -d $out/bin
    if [[ ! -e $out/bin/$packageName ]]; then
      ln -s $out/lib/node_modules/$packageName/bin/$packageName.js $out/bin/$packageName
    fi
  '';
}
