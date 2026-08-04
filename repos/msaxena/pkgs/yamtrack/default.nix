{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  makeWrapper,
  testers,
}:

let
  django-select2 = python3.pkgs.callPackage ./django-select2.nix { };

  pythonEnv = python3.withPackages (
    ps: with ps; [
      aiohttp
      apprise
      beautifulsoup4
      celery
      croniter
      defusedxml
      django
      django-allauth
      django-celery-beat
      django-celery-results
      django-debug-toolbar
      django-health-check
      django-model-utils
      django-redis
      django-select2
      django-simple-history
      django-widget-tweaks
      gunicorn
      hiredis
      icalendar
      pillow
      psycopg
      psycopg-pool
      python-decouple
      # nixpkgs' redis-py is currently ahead of both Yamtrack's own pin
      # (pyproject.toml: redis[hiredis]~=7.4.0) and, more importantly,
      # kombu's declared hard ceiling (kombu[redis]'s own extras require
      # "redis<6.5"; Celery's broker transport goes through kombu, not
      # Yamtrack's own redis pin). The existing VM test's celery-ping health
      # check already round-trips a real task through this exact path and
      # passes, but redis-py 8's changed connection-timeout defaults could
      # still surface as spurious broker timeouts under real load that a
      # smoke test wouldn't catch. If Celery task delivery ever misbehaves,
      # check here first.
      redis
      requests
      requests-ratelimiter
      unidecode
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "yamtrack";
  version = "0.25.3";

  src = fetchFromGitHub {
    owner = "FuzzyGrim";
    repo = "Yamtrack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6XuV0+2Metrxngkhhbx10Km6s0zWYT0ilrLAwTC7j3c=";
  };

  nativeBuildInputs = [
    makeWrapper
    pythonEnv
  ];

  # Yamtrack's settings.py assumes it lives in a writable app directory (the
  # Docker image copies the source tree into a writable container layer). On
  # NixOS the source tree is read-only, so two things need to move to
  # externally-managed, writable locations: the unconditional `db/` directory
  # creation on import, and the sqlite file path. Everything else BASE_DIR is
  # used for (STATIC_ROOT, STATICFILES_DIRS, templates) stays read-only, which
  # is fine since collectstatic runs once at build time.
  postPatch = ''
    substituteInPlace src/config/settings.py \
      --replace-fail \
        'Path(BASE_DIR / "db").mkdir(parents=True, exist_ok=True)' \
        '# db directory is provided externally by the NixOS module (SQLITE_PATH)' \
      --replace-fail \
        '"NAME": BASE_DIR / "db" / "db.sqlite3",' \
        '"NAME": config("SQLITE_PATH", default=BASE_DIR / "db" / "db.sqlite3"),'
  '';

  buildPhase = ''
    runHook preBuild

    DJANGO_SETTINGS_MODULE=config.settings \
      ${pythonEnv}/bin/python src/manage.py collectstatic --noinput

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/yamtrack
    cp -r src $out/share/yamtrack/src

    mkdir -p $out/bin

    makeWrapper ${pythonEnv}/bin/python $out/bin/yamtrack-manage \
      --add-flags "$out/share/yamtrack/src/manage.py"

    makeWrapper ${pythonEnv}/bin/gunicorn $out/bin/yamtrack-gunicorn \
      --add-flags "--chdir $out/share/yamtrack/src --config $out/share/yamtrack/src/config/gunicorn.py config.wsgi:application"

    makeWrapper ${pythonEnv}/bin/celery $out/bin/yamtrack-celery \
      --add-flags "--workdir $out/share/yamtrack/src -A config"

    runHook postInstall
  '';

  passthru.tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    yamtrack = testers.nixosTest {
      name = "yamtrack";

      nodes.machine =
        { pkgs, ... }:
        {
          imports = [ ../../nixos-modules/yamtrack.nix ];

          services.yamtrack = {
            enable = true;
            package = finalAttrs.finalPackage;
            port = 8001;
            openFirewall = true;
            environmentFiles = [
              (pkgs.writeText "yamtrack-env" ''
                SECRET=test-secret-key-not-for-production
              '')
            ];
          };

          services.redis.servers.yamtrack = {
            enable = true;
            port = 6379;
            bind = "127.0.0.1";
          };
        };

      testScript = ''
        machine.wait_for_unit("redis-yamtrack.service")
        machine.wait_for_unit("yamtrack-migrate.service")
        machine.wait_for_unit("yamtrack-worker.service")
        machine.wait_for_unit("yamtrack.service")
        machine.wait_for_open_port(8001)

        # /health/ (health_check.Cache, .Database, .contrib.celery.Ping,
        # .contrib.redis.Redis) only returns 200 once the celery worker has
        # registered with the broker; until then it 500s. -f makes curl
        # fail (and wait_until_succeeds retry) on non-2xx responses.
        machine.wait_until_succeeds(
          "curl -sf http://localhost:8001/health/",
          timeout=60,
        )
      '';
    };

    # Exercises database.createLocally's peer-auth wiring separately, since
    # it is a distinct code path from the sqlite default above.
    yamtrackPostgres = testers.nixosTest {
      name = "yamtrack-postgres";

      nodes.machine =
        { pkgs, ... }:
        {
          imports = [ ../../nixos-modules/yamtrack.nix ];

          services.yamtrack = {
            enable = true;
            package = finalAttrs.finalPackage;
            port = 8001;
            celery.enable = false;
            database.createLocally = true;
            environmentFiles = [
              (pkgs.writeText "yamtrack-env" ''
                SECRET=test-secret-key-not-for-production
              '')
            ];
          };
        };

      testScript = ''
        machine.wait_for_unit("postgresql.service")
        machine.wait_for_unit("yamtrack-migrate.service")
        machine.wait_for_unit("yamtrack.service")
        machine.wait_for_open_port(8001)
        machine.succeed(
          "runuser -u postgres -- psql yamtrack -c \"select count(*) from django_migrations;\""
        )
      '';
    };
  };

  meta = {
    description = "Self hosted media tracker for movies, TV shows, anime, manga, games, books and more";
    longDescription = ''
      Yamtrack is a self-hosted Django application for tracking the media you
      watch, read and play. It integrates with TMDB, MyAnimeList, IGDB,
      Hardcover, ComicVine and other providers for metadata, and supports
      importing from and scrobbling to Trakt, AniList, SIMKL and others.

      This package builds Yamtrack from source against nixpkgs' Python
      package set instead of using the upstream Docker image, so it does not
      include nginx or supervisord. Use the accompanying `nixosModules.yamtrack`
      NixOS module to run it as systemd services.
    '';
    homepage = "https://github.com/FuzzyGrim/Yamtrack";
    changelog = "https://github.com/FuzzyGrim/Yamtrack/releases/tag/v${finalAttrs.version}";
    # Yamtrack's LICENSE file is the unmodified FSF AGPLv3 template (no
    # project-specific "or later" grant attached to it, and the README just
    # says "AGPL-3.0") -- same as upstream TREK's LICENSE in this repo, which
    # is classified agpl3Only. Absent an explicit "or later" grant, "only" is
    # the correct default rather than assuming the boilerplate's optional
    # "or any later version" clause was adopted.
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
