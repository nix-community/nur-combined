{
  lib,
  stdenv,
  fetchFromGitea,
  autoreconfHook,
  pkg-config,
  texinfo,
  makeWrapper,
  guile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "msg-cli";
  version = "0.1.1";

  src = fetchFromGitea {
    domain = "forge.superkamiguru.org";
    owner = "MSG";
    repo = "msg-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M/MksKwmV/PQxRtv9cT3KwMquhu2yUyBI9+jQL/vsfA=";
  };

  postPatch = ''
    substituteInPlace msg/machine.scm \
      --replace-fail "/opt/homebrew/bin/" "" \
      --replace-fail "/usr/local/bin/" ""
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    texinfo # For makeinfo
    makeWrapper
  ];

  buildInputs = [ guile ];

  postInstall = ''
    wrapProgram $out/bin/msg \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH"
  '';

  meta = {
    description = "MacOS Subsystem for Guix";
    homepage = "https://forge.superkamiguru.org/MSG/msg-cli";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "msg";
  };
})
