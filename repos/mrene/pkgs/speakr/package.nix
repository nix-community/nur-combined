{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  writeText,
  python313,
  tailwindcss_3,
  ffmpeg-headless,
  makeWrapper,
  # Semantic search ("Inquire") and speaker embeddings; pulls in PyTorch.
  withEmbeddings ? false,
}:
let
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "murtaza-nasir";
    repo = "speakr";
    tag = "v${version}";
    hash = "sha256-FV3WgMTT7fS9HRbQkduL/+Z2a4kK2hIk2KCoug0Lv3s=";
  };

  # Upstream targets Python 3.11. 3.14 maps .wav to audio/vnd.wave, which
  # changes the MIME type Speakr stores and serves for uploads.
  dependencies =
    ps:
    with ps;
    [
      authlib
      babel
      bleach
      boto3
      email-validator
      flask
      flask-bcrypt
      flask-limiter
      flask-login
      flask-sqlalchemy
      flask-wtf
      gunicorn
      httpx
      itsdangerous
      joserfc
      markdown
      numpy
      openai
      pillow
      psycopg2
      python-dateutil
      python-docx
      python-dotenv
      pytz
      pywebpush
      redis
      requests
      scikit-learn
      scipy
      sqlalchemy
      tzdata
      werkzeug
    ]
    ++ lib.optionals withEmbeddings [
      huggingface-hub
      sentence-transformers
    ];
  python = python313.withPackages dependencies;
  testPython = python313.withPackages (
    ps:
    dependencies ps
    ++ [
      ps.pytest
      ps.pytest-xdist
    ]
  );

  # JS/CSS/fonts for static/vendor. vendor.json copies the production
  # URL -> SHA-256 list of scripts/download_offline_deps.py; the script then
  # runs against these local copies, so it still verifies every file and
  # rewrites the Font Awesome CSS, and fails on a URL missing from vendor.json.
  vendorFiles = writeText "speakr-vendor-files.json" (
    builtins.toJSON (
      builtins.mapAttrs (url: sha256: fetchurl { inherit url sha256; }) (lib.importJSON ./vendor.json)
    )
  );
  downloadOfflineDeps = writeText "download-offline-deps.py" ''
    import json, runpy, urllib.request

    files = json.load(open("${vendorFiles}"))
    urllib.request.urlopen = lambda url, timeout=None: open(files[url], "rb")
    runpy.run_path("scripts/download_offline_deps.py", run_name="__main__")
  '';
in
stdenvNoCC.mkDerivation {
  pname = "speakr";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
    python
    tailwindcss_3
  ];

  buildPhase = ''
    runHook preBuild
    PRODUCTION=1 python ${downloadOfflineDeps}
    tailwindcss -c tailwind.config.js -i static/css/tailwind.input.css \
      -o static/css/tailwind.css --minify
    runHook postBuild
  '';

  doCheck = true;
  nativeCheckInputs = [ ffmpeg-headless ];
  # Deselected tests resolve example.com. stdenv points SSL_CERT_FILE at a
  # missing file, which httpx refuses when the app module is imported.
  # test_hot_settings_registration.py asserts the hot settings are not module
  # attributes, but monkeypatch.setattr(..., raising=False) in other tests
  # leaves ENABLE_INTERNAL_SHARING behind as one; it fails whenever xdist puts
  # those in the same worker first, so it runs in its own process.
  checkPhase = ''
    runHook preCheck
    unset SSL_CERT_FILE
    export HOME=$TMPDIR
    pytest="${testPython}/bin/python -m pytest -p no:cacheprovider -q"
    $pytest tests/test_hot_settings_registration.py
    $pytest -n $NIX_BUILD_CORES -m "not slow" --ignore=tests/e2e \
      --ignore=tests/test_hot_settings_registration.py \
      --deselect tests/test_webhooks.py::test_is_url_safe_accepts_https_public \
      --deselect tests/test_webhooks.py::test_create_webhook_returns_secret_once_and_omits_thereafter \
      --deselect tests/test_webhooks.py::test_per_user_cap_enforced
    runHook postCheck
  '';

  # The app reads VERSION from the working directory and resolves static/,
  # templates/ and src/assets/ relative to its sources.
  installPhase = ''
    runHook preInstall

    app=$out/share/speakr
    mkdir -p $app
    cp -r src static templates scripts VERSION $app/
    # The store is read-only, so compile here instead of on every worker start;
    # drop the bytecode the tests left behind first.
    find $app -name __pycache__ -prune -exec rm -rf {} +
    python -m compileall -q $app/src $app/scripts

    wrap() {
      makeWrapper "$1" "$2" \
        --chdir $app \
        --set PYTHONPATH $app \
        --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]} \
        "''${@:3}"
    }
    wrap ${python}/bin/gunicorn $out/bin/speakr --add-flags "--no-control-socket src.app:app"
    wrap ${python}/bin/python $out/bin/speakr-python

    runHook postInstall
  '';

  passthru = {
    inherit python;
  };

  meta = {
    description = "Self-hosted audio transcription and note-taking with speaker diarization and AI summaries";
    homepage = "https://github.com/murtaza-nasir/speakr";
    changelog = "https://github.com/murtaza-nasir/speakr/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "speakr";
    platforms = lib.platforms.linux;
  };
}
