{
  lib,
  beamPackages,
  fetchFromGitLab,
  cmake,
  pkg-config,
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
  version = "2.9.1";

  src = fetchFromGitLab {
    domain = "git.pleroma.social";
    owner = "pleroma";
    repo = "pleroma";
    rev = "v${version}";
    hash = "sha256-mZcr+LlRQFDZVU5yAm0XkFdFHCDp4DZNLoVUlWxknMI=";
  };

  patches = [
    ./Revert-Config-Restrict-permissions-of-OTP-config.patch
    ./Search-Add-pgroonga.patch
    ./Set-fetch-emoji-timeout-to-120s.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    file
    vips
    glib.dev
  ];

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    hash = "sha256-ZmOWyScyeSponfBg0huIFtK6WJE9ngROoL9OCEhJSy8=";

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

  preBuild = ''
    export HOME=$TMPDIR
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

    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "ActivityPub microblogging server";
    homepage = "https://git.pleroma.social/pleroma/pleroma";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.unix;
    broken = versionOlder beamPackages.erlang.version "26.0.0";
  };
}
