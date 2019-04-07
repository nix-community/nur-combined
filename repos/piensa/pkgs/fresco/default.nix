{ yarn2nix, fetchgit }:

yarn2nix.mkYarnPackage {
  name = "fresco";
  yarnNix = ./yarn.nix;
  yarnLock = ./yarn.lock;

  preInstall = ''
    yarn build
  '';

  postInstall = ''
    ls $out/node_modules/fresco-app/build
    cp -r $out/node_modules/fresco-app/build/* $out/
    rm -rf $out/node_modules
    rm -rf $out/bin
  '';

  patches = [ ./0001-fresco-changes.patch ];


  src = fetchgit {
    rev = "5c6be2353338e4fe481e1784a4c8fdf5f25ea17e";
    url = "https://github.com/go-spatial/fresco";
    sha256 = "15mrii51k8ba7apyxp721xp3214l5lxz5hh91yyzygyxvswyl0p4";
  };

}
