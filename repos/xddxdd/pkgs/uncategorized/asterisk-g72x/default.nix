{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  autoreconfHook,
  bcg729,
  asterisk,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "asterisk-g72x";
  version = "0-unstable-2026-09-07";
  src = fetchFromGitHub {
    owner = "arkadijs";
    repo = "asterisk-g72x";
    rev = "5106838f3aabf8fe09fa3780a8e9d3ed4c2a0063";
    hash = "sha256-6NF5ISpaXrEZUfFilWVeRAJnCb1b+Qaaq7p4AJHqjf0=";
  };
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [
    asterisk
    bcg729
  ];

  patches = [ ./remove-march.patch ];

  configureFlags = [ "--with-bcg729" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/arkadijs/asterisk-g72x";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
    homepage = "https://github.com/arkadijs/asterisk-g72x";
    license = lib.licenses.unfreeRedistributable;
  };
})
