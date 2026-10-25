{
  lib,
  beamPackages,
  fetchFromForgejo,
  cmake,
  pkg-config,
  writableTmpDirAsHomeHook,
  file,
  vips,
  glib,
  exiftool,
  imagemagick,
  ffmpeg-headless,
  nixosTests,
  nix-update-script,
}:

beamPackages.mixRelease rec {
  pname = "pleroma";
  version = "2.11.0";

  src = fetchFromForgejo {
    domain = "git.pleroma.social";
    owner = "pleroma";
    repo = "pleroma";
    rev = "v${version}";
    hash = "sha256-yQcvmoqKepL5l1YbWsgTBN0XGKSBLF4Rz9n+SJTcfo0=";
  };

  patches = [
    ./Revert-Config-Restrict-permissions-of-OTP-config.patch
    ./Search-Add-pgroonga.patch
    ./Set-fetch-emoji-timeout-to-120s.patch
    ./Stats-avoid-citext-regex-splitting-for-peer-domains.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    writableTmpDirAsHomeHook
  ];
  buildInputs = [
    file
    vips
    glib.dev
  ];

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    hash = "sha256-4+NIHXxPGhWSh2KDEnqaqK2K1ddf7mGdwwUZ9e0Oc2c=";

    postInstall = ''
      substituteInPlace "$out/http_signatures/mix.exs" \
        --replace-fail ":logger" ":logger, :public_key"

      # Pleroma adds some things to the `mime` package's configuration, which
      # requires it to be recompiled. However, we can't just recompile things
      # like we would on other systems. Therefore, we need to add it to mime's
      # compile-time config too, and also in every package that depends on
      # mime, directly or indirectly. We take the lazy way out and just add it
      # to every dependency – it won't make a difference in packages that don't
      # depend on `mime`.
      for dep in "$out/"*; do
        mkdir -p "$dep/config"
        cat ${./mime.exs} >>"$dep/config/config.exs"
      done
    '';
  };

  dontUseCmakeConfigure = true;

  env.VIX_COMPILATION_MODE = "PLATFORM_PROVIDED_LIBVIPS";

  postBuild = ''
    # Digest and compress static files
    rm -f priv/static/READ_THIS_BEFORE_TOUCHING_FILES_HERE
    mix do deps.loadpaths --no-deps-check, phx.digest --no-compile
  '';

  postInstall = ''
    for f in $(find $out/bin/ -type f -executable); do
      wrapProgram "$f" \
        --prefix PATH : ${
          lib.makeBinPath [
            exiftool
            imagemagick
            ffmpeg-headless
          ]
        }
    done
  '';

  passthru = {
    tests.pleroma = nixosTests.pleroma;

    inherit mixFodDeps;

    # Used to make sure the service uses the same version of elixir as
    # the package
    elixirPackage = beamPackages.elixir;

    updateScript = nix-update-script {
      extraArgs = [
        "--url=https://git.pleroma.social/pleroma/pleroma.git"
        "--version-regex=^v(2\\..*)$"
      ];
    };
  };

  meta = {
    description = "ActivityPub microblogging server";
    homepage = "https://pleroma.social";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.unix;
    broken = lib.versionOlder beamPackages.erlang.version "27.0.0";
  };
}
