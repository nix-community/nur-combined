{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  python3,
  stdenv,
  makeWrapper,
}:
let
  version = "0.5.10";
  source = fetchFromGitHub {
    owner = "tubearchivist";
    repo = "tubearchivist";
    rev = "v${version}";
    hash = "sha256-NzqHWyenEooFCD4Int2ULavRNQs1FKpbCoY3/6/PF/M=";
  };

  frontend = buildNpmPackage {
    pname = "tubearchivist-frontend";
    inherit version;
    buildInputs = [ nodejs ];
    src = "${source}/frontend";
    npmDepsHash = "sha256-eCz1b0peMe4rA6aROnN0zOE1fB6thMnDLH4hkbxORmA=";
    npmBuildScript = "build:deploy";
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out
    '';
  };

  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      django = prev.django_5;
    };
  };

  pythonEnv = python.withPackages (ps: [
    ps.apprise
    ps.celery
    ps.django-auth-ldap
    ps.django-celery-beat
    ps.django-cors-headers
    ps.django_5
    ps.djangorestframework
    ps.drf-spectacular
    ps.pillow
    ps.redis
    ps.requests
    ps.ryd-client
    ps.uvicorn
    ps.whitenoise
    ps.yt-dlp
  ]);
in
stdenv.mkDerivation {
  pname = "tubearchivist";
  inherit version;
  src = source;

  nativeBuildInputs = [ makeWrapper ];

  patchPhase = "";

  # Override the /app/static path with the Nix path to the frontend
  # Also allow the STATIC_ROOT property to be set
  # through the environment variable TA_STATIC_ROOT
  installPhase = ''
    mkdir -p $out/{bin,share/tubearchivist}
    cp -r --no-preserve=mode \
      $src/backend/* \
      $src/docker_assets/run.sh \
      $src/docker_assets/backend_start.py \
      $out/share/tubearchivist
    chmod +x $out/share/tubearchivist/run.sh

    # Disable writing to the NGINX config
    sed --in-place \
      --expression='s/self\._disable_static_auth/# &/' \
      --expression='s/self\._ta_[a-z_]*_overwrite/# &/' \
      $out/share/tubearchivist/config/management/commands/ta_envcheck.py

    sed --in-place \
      --expression='s:^STATIC_ROOT\s*=.*:STATIC_ROOT = environ.get("TA_STATIC_ROOT"):' \
      --expression='s:^STATICFILES_DIRS\s*=.*:STATICFILES_DIRS = ("${frontend}",):' \
      $out/share/tubearchivist/config/settings.py

    sed --in-place \
      '1i cd "$(dirname "$0")"' \
      $out/share/tubearchivist/run.sh
    makeWrapper $out/share/tubearchivist/run.sh $out/bin/tubearchivist \
      --prefix PATH : ${pythonEnv}/bin \
      --set TA_APP_DIR $out/share/tubearchivist
  '';

  meta = {
    description = "Your self hosted YouTube media server";
    homepage = "https://tubearchivist.com";
    license = lib.licenses.gpl3Only;
    broken = true;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    badPlatforms = lib.platforms.darwin;
    maintainers = [ lib.maintainers.skyesoss ];
  };
}
