{ lib
, dataDir ? "/var/lib/koillection"
  # REVIEW: This supposed to be aliased by the caller, which means it shouldn't
  # go in by-name, I think.
, php83
, fetchFromGitHub
, mkYarnPackage
, fetchYarnDeps
}:

php83.buildComposerProject (finalAttrs: {
  pname = "koillection";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "benjaminjonard";
    repo = "koillection";
    rev = finalAttrs.version;
    hash = "sha256-r2rkHhp0F5QfwJuKeu4UdPoluDXxpyhYpie1zUk1h5c=";
  };

  frontend = mkYarnPackage {
    inherit (finalAttrs) pname version;

    src = "${finalAttrs.src}/assets";

    offlineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/assets/yarn.lock";
      hash = "";
    };
  };

  patches = [
    ./koillection-dirs.patch
  ];

  postPatch = ''
    substituteInPlace src/Kernel.php \
      --replace "@dataDir@" "${dataDir}"
  '';

  # Lock file uses exact constraints, which Composer doesn't like.
  composerStrictValidation = false;
  # Actually installs plugins, i.e., Symfony.
  composerNoPlugins = false;
  vendorHash = "sha256-LU9ZN4qUNUpSBGH6AChw3qU4RjgsoPJmLL01FS7UKRQ=";

  postInstall = ''
    local koillection_out=$out/share/php/koillection

    rm -R $koillection_out/public/uploads
    ln -s ${dataDir}/.env $koillection_out/.env.local
    ln -s ${dataDir}/public/uploads $koillection_out/public/uploads

    cp -r ${finalAttrs.frontend} assets/
  '';

  passthru = {
    phpPackage = php83;
  };

  meta = {
    description = "Self-hosted service allowing users to manage any kind of collections";
    homepage = "https://github.com/benjaminjonard/koillection";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    broken = true; # Blocked on NixOS/nixpkgs#254369
  };
})
