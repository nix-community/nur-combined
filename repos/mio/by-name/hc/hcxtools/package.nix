{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  curl,
  openssl,
  zlib,
  nix-update-script,
}:

# Nixpkgs' hcxtools is marked linux-only, but it builds and runs on Darwin as
# well (AirJack needs its hcxpcapngtool); the only change required is creating
# the install prefix's bin directory, which the upstream install rules assume
# exists.
stdenv.mkDerivation (finalAttrs: {
  pname = "hcxtools";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "ZerBea";
    repo = "hcxtools";
    tag = finalAttrs.version;
    hash = "sha256-LvX1RPkNoo/neRsHFHYts9S8pZlaobxxjb8x/zSf3PA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    openssl
    zlib
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  preInstall = ''
    mkdir -p "${placeholder "out"}/bin"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools for capturing wlan traffic and conversion to hashcat and John the Ripper formats";
    homepage = "https://github.com/ZerBea/hcxtools";
    changelog = "https://github.com/ZerBea/hcxtools/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "hcxpcapngtool";
    maintainers = with lib.maintainers; [ dywedir ];
  };
})
