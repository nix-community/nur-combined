{
  lib,
  php,
  makeWrapper,
  versionCheckHook,

  withSqlite ? true,
  withPostgresql ? false,
  withMysql ? false,
  withMssql ? false,

  sources,
  source ? sources.shlink,
}:

php.buildComposerProject2 (finalAttrs: {
  inherit (source) pname version src;

  postPatch = ''
    substituteInPlace module/Core/src/Config/Options/AppOptions.php \
      --replace-fail '%SHLINK_VERSION%' '${finalAttrs.version}'

    cp ${./path.php} config/autoload/zz-nix.global.php
    substituteInPlace config/config.php \
      --replace-fail "'data/cache/app_config.php'" "(getenv('SHLINK_CACHE_DIR') ?: (getenv('CACHE_DIRECTORY') ?: 'data/cache')) . '/app_config.php'"
    substituteInPlace module/Core/src/ObjectMapper/MapperBuilderWithCacheDelegatorFactory.php \
      --replace-fail "\$cache = new FileSystemCache('data/cache/valinor');" \
        "\$config = \$container->get('config');
          \$cache = new FileSystemCache(
              \$config['cache']['valinor_cache_dir'] ?? 'data/cache/valinor',
          );"
  '';

  inherit (finalAttrs.passthru) php;

  vendorHash = "sha256-YbUmXzR17XHOqMixFiSGDYJfLPha5R2zP7dTJ6CLHPU=";

  composerLock = ./composer.lock;
  composerNoDev = true;
  composerNoScripts = true;
  composerNoPlugins = false;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    makeWrapper ${lib.getExe finalAttrs.php} $out/bin/shlink \
      --add-flags "$out/share/php/shlink/bin/cli" \
      --set-default SHLINK_RUNTIME nix \
      --set-default SHLINK_DATA_DIR "/var/lib/shlink" \
      --set-default SHLINK_CACHE_DIR "/var/cache/shlink"
  '';

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];

  passthru = {
    php = php.withExtensions (
      { enabled, all }:
      enabled
      ++ (with all; [
        curl
        mbstring
        pdo
        intl
        gd
        gmp
        bcmath
        sockets
        apcu
      ])
      ++ lib.optional withSqlite all.pdo_sqlite
      ++ lib.optional withPostgresql all.pdo_pgsql
      ++ lib.optional withMysql all.pdo_mysql
      ++ lib.optional withMssql all.pdo_sqlsrv
    );
    # nix-update auto -u
    updateScript = ./update.sh;
  };

  meta = {
    description = "Self-hosted URL shortener with CLI and REST interfaces";
    homepage = "https://shlink.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = php.meta.platforms;
    mainProgram = "shlink";
  };
})
