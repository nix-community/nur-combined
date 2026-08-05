{
  cypress,
  fetchFromGitHub,
  fetchNpmDeps,
  lib,
  nodejs,
  npmHooks,
  php,
  nix-update-script,
}:
(php.buildComposerProject2 (finalAttrs: {
  pname = "cdash";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "CDash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/QtKApzB5g46FVV/WUwTvTOADkaAIZW6QlPpd8mN6+w=";
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-NjC/bpyb0cpfA8Xj/cPf/0CLWkMjat+N/E17TRm3t+U=";
  };

  env = {
    CYPRESS_INSTALL_BINARY = "0";
    CYPRESS_RUN_BINARY = lib.getExe cypress;
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  postBuild = ''
    npm run prod
  '';

  postInstall = ''
    mkdir -p $out/bin
    cat > $out/bin/artisan << EOF
    #!/bin/sh
    export QUEUE_CONNECTION="\''${QUEUE_CONNECTION:-sync}"
    export LARAVEL_STORAGE_PATH="\''${LARAVEL_STORAGE_PATH:-"\$STATE_DIRECTORY"}"
    export APP_SERVICES_CACHE="\$LARAVEL_STORAGE_PATH/bootstrap/cache/services.php"
    export APP_PACKAGES_CACHE="\$LARAVEL_STORAGE_PATH/bootstrap/cache/packages.php"
    export APP_CONFIG_CACHE="\$LARAVEL_STORAGE_PATH/bootstrap/cache/config.php"
    export APP_ROUTES_CACHE="\$LARAVEL_STORAGE_PATH/bootstrap/cache/routes.php"
    export APP_EVENTS_CACHE="\$LARAVEL_STORAGE_PATH/bootstrap/cache/events.php"
    export LIGHTHOUSE_SCHEMA_CACHE_PATH="\$LARAVEL_STORAGE_PATH/bootstrap/cache/lighthouse-schema.php"
    exec $out/share/php/cdash/artisan "\$@"
    EOF
    chmod +x $out/bin/artisan
  '';

  php = php.buildEnv {
    extensions =
      {
        enabled,
        all,
      }:
      enabled ++ [ all.xsl ];
  };
  vendorHash = "sha256-uXPbZUIQpfOlACyKxHXxmiI1eZCiRTMAkEyi2Z7u9xs=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CDash is a web-based software testing server";
    longDescription = ''
      CDash is an open source, web-based software testing server. CDash
      aggregates, analyzes and displays the results of software testing
      processes submitted from clients located around the world.
      Developers depend on CDash to convey the state of a software
      system, and to continually improve its quality.
      CDash is a part of a larger software process that integrates
      Kitware’s CMake, CTest, and CPack tools, as well as other external
      packages used to design, manage and maintain large-scale software
      systems.
    '';
    homepage = "https://www.cdash.org";
    changelog = "https://github.com/Kitware/CDash/releases";
    mainProgram = "artisan";
    # Needs modification
    broken = true;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})).overrideAttrs
  (oldAttrs: {
    # Needed because buildComposerProject2 overrides this
    meta = oldAttrs.meta // {
      platforms = [ "x86_64-linux" ];
    };
  })
