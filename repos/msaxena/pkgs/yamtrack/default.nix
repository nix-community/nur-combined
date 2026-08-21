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
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "FuzzyGrim";
    repo = "Yamtrack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9eJHlW+s+9VIKicPCrgHyUtlOqbEDm/LFm0p9iOPc8w=";
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
            # The module's new default; set explicitly to document that this
            # is now the co-located proxy's port, not gunicorn's (which binds
            # loopback-only on its own fixed internal port and is never
            # reachable here).
            port = 8000;
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
        import re

        machine.wait_for_unit("redis-yamtrack.service")
        machine.wait_for_unit("yamtrack-migrate.service")
        machine.wait_for_unit("yamtrack-worker.service")
        machine.wait_for_unit("yamtrack.service")
        machine.wait_for_unit("yamtrack-proxy.service")
        machine.wait_for_open_port(8000)

        # /health/ (health_check.Cache, .Database, .contrib.celery.Ping,
        # .contrib.redis.Redis) only returns 200 once the celery worker has
        # registered with the broker; until then it 500s. -f makes curl
        # fail (and wait_until_succeeds retry) on non-2xx responses. Port
        # 8000 is the co-located proxy, not gunicorn directly, so this also
        # exercises its reverse_proxy path end to end.
        machine.wait_until_succeeds(
          "curl -sf http://localhost:8000/health/",
          timeout=120,
        )

        with subtest("proxy serves collectstatic's output directly"):
            # Don't hardcode a filename (STATIC_ROOT's contents depend on
            # whatever apps happen to ship static/ dirs) -- discover a real
            # collected asset at runtime and fetch it through the proxy's
            # own port, with no separate reverse proxy involved.
            static_root = "${finalAttrs.finalPackage}/share/yamtrack/src/staticfiles"
            # `-print -quit` (not `| head -n1`) to avoid a broken-pipe exit
            # code from `find`/`sort` once `head` closes the pipe early.
            sample_file = machine.succeed(
                f"find {static_root} -type f -print -quit"
            ).strip()
            rel_path = sample_file[len(static_root):].lstrip("/")
            machine.succeed(f"curl -sf -o /dev/null http://localhost:8000/static/{rel_path}")

        with subtest("registration succeeds through the proxy alone"):
            # The check that a healthy-looking systemd unit set does NOT
            # cover: django-allauth's per-IP signup rate limiter (default
            # ACCOUNT_RATE_LIMITS "signup": "20/m/ip") calls get_client_ip()
            # on every POST to /accounts/signup/, which raises
            # PermissionDenied (403) whenever ALLAUTH_TRUSTED_CLIENT_IP_HEADER
            # ("X-Real-IP", set whenever not running via manage.py
            # runserver/test -- see settings.py) is configured but the header
            # itself is missing from the request. Before the proxy set
            # X-Real-IP, this 403ed on every single signup/login attempt
            # while every unit above still reported healthy.
            #
            # Mirror Django's real cookie+token CSRF flow: GET the signup
            # page to obtain both the csrftoken cookie and the
            # csrfmiddlewaretoken hidden input, then POST them back together
            # with matching Origin/Referer headers. Retried: gunicorn's
            # preload_app import (WEB_CONCURRENCY=1, the whole INSTALLED_APPS
            # list) can take upwards of 20+ seconds to complete under this
            # test's emulated CPU -- much longer than on real hardware --
            # during which Caddy's reverse_proxy can return a transient
            # incomplete response even though its own /health/ check above
            # already passed once. django-allauth's rate limiter would 403
            # (not merely return an incomplete/empty body) regardless of
            # timing, so retrying here doesn't mask the actual X-Real-IP bug
            # this test exists to catch.
            csrf_match = None
            for _ in range(150):
                status, out = machine.execute(
                    "curl -sf -c /tmp/yamtrack-cookies.txt http://localhost:8000/accounts/signup/"
                )
                if status == 0:
                    csrf_match = re.search(
                        r'name="csrfmiddlewaretoken" value="([^"]+)"', out
                    )
                    if csrf_match is not None:
                        break
                machine.execute("sleep 1")
            assert csrf_match is not None, (
                "csrfmiddlewaretoken not found on signup page after retrying for 150s"
            )
            csrf_token = csrf_match.group(1)

            status = machine.succeed(
                "curl -s -o /tmp/post-result.html -w '%{http_code}' "
                "-b /tmp/yamtrack-cookies.txt "
                "-H 'Origin: http://localhost:8000' "
                "-H 'Referer: http://localhost:8000/accounts/signup/' "
                f"--data-urlencode 'csrfmiddlewaretoken={csrf_token}' "
                "--data-urlencode 'username=e2e-registration-test' "
                "--data-urlencode 'password1=Correct-Horse-Battery-Staple9' "
                "--data-urlencode 'password2=Correct-Horse-Battery-Staple9' "
                "http://localhost:8000/accounts/signup/"
            ).strip()
            if status != "302":
                print(
                    "signup POST failed -- response body:",
                    machine.execute("cat /tmp/post-result.html")[1],
                )
                print(
                    "signup POST failed -- gunicorn journal:",
                    machine.execute("journalctl -u yamtrack.service --no-pager -n 60")[1],
                )
            assert status == "302", (
                f"expected a redirect (302) after successful signup, got HTTP {status} "
                "-- see the response body/journal logged above"
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
            # See the sqlite-backed test above: this is now the co-located
            # proxy's port, not gunicorn's fixed internal one, and must not
            # collide with it.
            port = 8000;
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
        machine.wait_for_unit("yamtrack-proxy.service")
        machine.wait_for_open_port(8000)
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
      itself include nginx or supervisord. Use the accompanying
      `nixosModules.yamtrack` NixOS module to run it as systemd services --
      as of the module's `port`/`host` breaking change (see that option's
      description), it provides its own co-located Caddy-based equivalent of
      upstream's bundled nginx layer (static-file serving, X-Real-IP), so
      nothing further is required for a working deployment.
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
