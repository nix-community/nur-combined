{
  lib,
  mkYarnPackage,
  fetchFromGitHub,
  yarn,
  nodejs-16_x,
}: let
  pname = "vscode-php-debug";
  data = lib.importJSON ./pin.json;
in
  mkYarnPackage {
    inherit pname;
    inherit (data) version;

    src = fetchFromGitHub {
      owner = "xdebug";
      repo = pname;
      rev = "v${data.version}";
      sha256 = data.srcHash;
    };

    packageJSON = ./package.json;

    yarn = yarn.override {nodejs = nodejs-16_x;};

    yarnNix = ./yarn.nix;
    yarnLock = ./yarn.lock;

    buildPhase = "yarn --offline run build";

    # Symlink the extension result directory to make it easier to find.
    fixupPhase = ''
      ln -s $out/libexec/php-debug/deps/php-debug/out $out/extension
    '';

    passthru.updateScript = ./update.sh;

    meta = {
      description = "PHP Debug Adapter Protocol";
      homepage = "https://github.com/xdebug/vscode-php-debug";
      license = lib.licenses.mit;
      maintainers = [lib.maintainers.etu];
      platforms = lib.platforms.all;
    };
  }
