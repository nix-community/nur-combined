{
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  lib,
  meson,
  ninja,
  cacert,
  cjson,
  cmake,
  git,
  libmicrohttpd,
  librist,
  mbedtls,
  openssl,
  pkg-config,
  srt,
  srtp,
  usrsctp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mistserver";
  version = "3.11.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "ddvtech";
    repo = "mistserver";
    tag = finalAttrs.version;
    hash = "sha256-rr4g1keM3rWJHtnu7BVN7yGFSXxEqgnHGuUp0fipbdE=";

    nativeBuildInputs = [
      cacert
      git
      meson
    ];

    postFetch = ''
      (
        cd "$out"
        for prj in subprojects/*.wrap; do
          meson subprojects download "$(basename "$prj" .wrap)"
          rm -rf subprojects/$(basename "$prj" .wrap)/.git
        done
        find subprojects -type d -name .git -prune -execdir rm -r {} +
      )
    '';
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    git
    pkg-config
  ];

  buildInputs = [
    cjson
    libmicrohttpd
    librist
    mbedtls
    openssl
    srt
    srtp
    usrsctp
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The official mistserver source repository - www.mistserver.com";
    homepage = "https://github.com/DDVTECH/mistserver";
    changelog = "https://github.com/DDVTECH/mistserver/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "MistController";
    platforms = lib.platforms.all;
  };
})
