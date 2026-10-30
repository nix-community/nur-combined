{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  uthash,
}:

let
  # zizzania's config.Makefile downloads the generic dry Makefile at build time;
  # nixpkgs has no package for it, so it is pinned here instead.
  dryMakefile = fetchFromGitHub {
    owner = "cyrus-and";
    repo = "dry-makefile";
    rev = "8d8a5747291c56056e080709575fb5b5f2ff287b";
    hash = "sha256-8a0sUDbG1DXU6sAXtDCZa3CSuhuVrj9CvycBK6YUr5I=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zizzania";
  version = "0-unstable-2023-12-09";

  src = fetchFromGitHub {
    owner = "cyrus-and";
    repo = "zizzania";
    rev = "c275231755bddfe0d1ff8830d98b817eba16df32";
    hash = "sha256-HbjQvariq7Tt4de2tQLZqrein6s3tZVipXQzxAxLYn8=";
  };

  buildInputs = [ libpcap ];

  # Both files config.Makefile would wget: the dry Makefile (project rules) and
  # uthash.h (the SETUP_HOOK the object files depend on).
  postPatch = ''
    cp ${dryMakefile}/Makefile Makefile
    mkdir -p external
    cp ${uthash}/include/uthash.h external/uthash.h
  '';

  buildPhase = ''
    runHook preBuild

    make release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/zizzania "$out/bin/zizzania"

    runHook postInstall
  '';

  meta = {
    description = "WPA/WPA2 handshake capture tool driven by libpcap";
    homepage = "https://github.com/cyrus-and/zizzania";
    license = lib.licenses.mit;
    mainProgram = "zizzania";
    platforms = lib.platforms.unix;
  };
})
