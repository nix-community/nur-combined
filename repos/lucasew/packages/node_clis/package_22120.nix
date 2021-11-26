{pkgs, ...}:
let 
  npmPackages = import ./package_data/default.nix {inherit pkgs;};
  a22120 = npmPackages."22120-git://github.com/c9fe/22120.git";
in pkgs.writeShellScriptBin "22120" ''
${a22120}/bin/archivist1 $*
''

