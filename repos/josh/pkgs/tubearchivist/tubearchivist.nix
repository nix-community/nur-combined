{
  lib,
  stdenvNoCC,
  buildNpmPackage,
  python3,
  fetchFromGitHub,

  atomicparsley,
  ffmpeg-headless,
  makeBinaryWrapper,

  nix-update-script,
  runCommand,
}:
let
  python = python3.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      django = pyprev.django_6;

      bgutil-ytdlp-pot-provider = pyfinal.buildPythonPackage {
        pname = "bgutil-ytdlp-pot-provider";
        version = "1.3.2-unstable-2026-08-22";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "bbilly1";
          repo = "bgutil-ytdlp-pot-provider";
          rev = "2a8772a693e7c5485ca65fd9cecd0f050f760ad1";
          hash = "sha256-vpp9DWk6wwh0IUjaOhsDoExLQpSv8a8elrgpaSEh4vM=";
        };

        sourceRoot = "source/plugin";

        build-system = [ pyfinal.hatchling ];

        dependencies = [ pyfinal.yt-dlp ];

        pythonImportsCheck = [ "yt_dlp_plugins.extractor.getpot_bgutil_http" ];
      };
    };
  };

  dependencies =
    ps: with ps; [
      apprise
      bgutil-ytdlp-pot-provider
      celery
      deepdiff
      django
      django-auth-ldap
      django-celery-beat
      django-cors-headers
      djangorestframework
      drf-spectacular
      pillow
      redis
      requests
      ryd-client
      uvicorn
      yt-dlp
    ];

  pythonEnv = python.withPackages dependencies;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tubearchivist";
  version = "0.5.12";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tubearchivist";
    repo = "tubearchivist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4S1gEz0BRAhlf5AQD+G1+S761WTLbdnwwP3xJU9DMh8=";
  };

  postPatch = ''
    substituteInPlace docker_assets/nginx.conf \
      --replace-fail "include proxy_params;" "proxy_set_header Host \$http_host; proxy_set_header X-Real-IP \$remote_addr; proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto \$scheme;" \
      --replace-fail "/app/staticfiles/" "@out@/share/tubearchivist/staticfiles/" \
      --replace-fail "root   /app/static;" "root   @out@/share/tubearchivist/static;"
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
    pythonEnv
  ];

  buildPhase = ''
    runHook preBuild

    cp -r backend app
    cp docker_assets/backend_start.py app/
    cp -r ${finalAttrs.passthru.frontend} app/static
    chmod -R u+w app/static

    (
      cd app
      TA_HOST=localhost TA_USERNAME=build TA_PASSWORD=build \
        ELASTIC_PASSWORD=build ES_URL=http://localhost:9200 \
        TA_CACHE_DIR="$TMPDIR" \
        python manage.py collectstatic --noinput
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r app $out/share/tubearchivist
    substitute docker_assets/nginx.conf $out/share/tubearchivist/nginx.conf \
      --subst-var out

    wrapperArgs=(
      --chdir $out/share/tubearchivist
      --prefix PYTHONPATH : $out/share/tubearchivist
      --prefix PATH : ${
        lib.makeBinPath [
          atomicparsley
          ffmpeg-headless
        ]
      }
      --set-default TA_APP_DIR $out/share/tubearchivist
      --set-default PYTHONUNBUFFERED 1
    )

    makeWrapper ${pythonEnv}/bin/python $out/bin/tubearchivist-manage \
      "''${wrapperArgs[@]}" \
      --add-flags $out/share/tubearchivist/manage.py
    makeWrapper ${pythonEnv}/bin/python $out/bin/tubearchivist-server \
      "''${wrapperArgs[@]}" \
      --add-flags $out/share/tubearchivist/backend_start.py
    makeWrapper ${pythonEnv}/bin/celery $out/bin/tubearchivist-celery \
      "''${wrapperArgs[@]}" \
      --add-flags "-A task"

    cat > $out/bin/tubearchivist <<EOF
    #!${stdenvNoCC.shell}
    set -e
    $out/bin/tubearchivist-manage ta_stop_on_error
    $out/bin/tubearchivist-manage migrate
    $out/bin/tubearchivist-manage ta_envcheck
    $out/bin/tubearchivist-manage ta_connection
    $out/bin/tubearchivist-manage ta_startup
    exec $out/bin/tubearchivist-server
    EOF
    chmod +x $out/bin/tubearchivist

    runHook postInstall
  '';

  passthru.frontend = buildNpmPackage {
    pname = "tubearchivist-frontend";
    inherit (finalAttrs) version src;

    sourceRoot = "${finalAttrs.src.name}/frontend";

    npmDepsHash = "sha256-GNUIlZl2uQAmZ76bBaoh4uVfTvo/LkL8Jmwow8Ptt4E=";

    npmBuildScript = "build:deploy";

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--subpackage"
      "frontend"
    ];
  };

  passthru.tests = {
    check =
      runCommand "test-tubearchivist-check"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          export TA_HOST=localhost TA_USERNAME=test TA_PASSWORD=test
          export ELASTIC_PASSWORD=test ES_URL=http://localhost:9200
          export TA_CACHE_DIR="$TMPDIR"
          tubearchivist-manage check
          tubearchivist-manage shell -c "import config.asgi, task.tasks, yt_dlp_plugins.extractor.getpot_bgutil_http"
          tubearchivist-celery report | grep -q "celery:${python.pkgs.celery.version}"
          touch $out
        '';

    pytest =
      runCommand "test-tubearchivist-pytest"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [
            (python.withPackages (
              ps:
              dependencies ps
              ++ [
                ps.pytest
                ps.pytest-django
              ]
            ))
          ];
        }
        ''
          cp -r --no-preserve=mode ${finalAttrs.src} source
          cd source
          export TA_HOST=localhost TA_USERNAME=test TA_PASSWORD=test
          export ELASTIC_PASSWORD=test ES_URL=http://localhost:9200
          export TA_CACHE_DIR="$TMPDIR"
          export DJANGO_SETTINGS_MODULE=config.settings PYTHONPATH=$PWD/backend
          python -m pytest backend -p no:cacheprovider \
            -k "not test_is_shorts and not TomScottGo and not IBRACORP"
          touch $out
        '';

    static =
      runCommand "test-tubearchivist-static"
        {
          __structuredAttrs = true;
        }
        ''
          share=${finalAttrs.finalPackage}/share/tubearchivist
          test -f $share/static/index.html
          test -f $share/static/img/default-video-thumb.jpg
          test -d $share/staticfiles/admin
          grep -q "root   $share/static;" $share/nginx.conf
          touch $out
        '';
  };

  meta = {
    description = "Self hosted YouTube media server";
    homepage = "https://www.tubearchivist.com";
    changelog = "https://github.com/tubearchivist/tubearchivist/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "tubearchivist";
    platforms = lib.platforms.all;
  };
})
