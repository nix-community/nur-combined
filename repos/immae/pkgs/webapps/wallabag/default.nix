{ varDir ? "/var/lib/wallabag"
, wallabag_config ? "/etc/wallabag/parameters.yml"
, ldap ? false
, composerEnv, fetchurl, lib }:
composerEnv.buildPackage rec {
  packages = {
    "fr3d/ldap-bundle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fr3d-ldap-bundle-5a8927c11af45fa06331b97221c6da1a4a237475";
        src = fetchurl {
          url = https://api.github.com/repos/Maks3w/FR3DLdapBundle/zipball/5a8927c11af45fa06331b97221c6da1a4a237475;
          sha256 = "168zkd82j200wd6h0a3lq81g5s2pifg889rv27q2g429nppsbfxc";
        };
      };
    };
    "zendframework/zend-ldap" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "zendframework-zend-ldap-b63c7884a08d3a6bda60ebcf7d6238cf8ad89f49";
        src = fetchurl {
          url = https://api.github.com/repos/zendframework/zend-ldap/zipball/b63c7884a08d3a6bda60ebcf7d6238cf8ad89f49;
          sha256 = "0mn4yqnb5prqhrbbybmw1i2rx7xf4s4wagbdq9qi55fa0vk3jgw9";
        };
      };
    };
  };
  noDev = true;
  doRemoveVendor = false;
  # Beware when upgrading, I probably messed up with the migrations table
  # (due to a psql bug in wallabag)
  version = "2.3.6";
  name = "wallabag-${version}";
  src = fetchurl {
    url = "https://static.wallabag.org/releases/wallabag-release-${version}.tar.gz";
    sha256 = "0m0dy3r94ks5pfxyb9vbgrsm0vrwdl3jd5wqwg4f5vd107lq90q1";
  };
  unpackPhase = ''
    unpackFile "$src"
    sourceRoot=${version}
    src=$PWD/${version}
    '';
  patches = lib.optionals ldap [ ./ldap.patch ];
  preInstall = ''
    export SYMFONY_ENV="prod"
  '';
  postInstall = ''
    rm -rf web/assets var/{cache,logs,sessions} app/config/parameters.yml data
    ln -sf ${wallabag_config} app/config/parameters.yml
    ln -sf ${varDir}/var/{cache,logs,sessions} var
    ln -sf ${varDir}/data data
    ln -sf ${varDir}/assets web/assets
  '';
}
