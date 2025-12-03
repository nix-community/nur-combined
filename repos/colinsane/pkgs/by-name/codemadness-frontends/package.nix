{
  lib,
  stdenv,
  fetchgit,
  libressl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "codemadness-frontends";
  version = "0.8";

  src = fetchgit {
    url = "git://git.codemadness.org/frontends";
    rev = finalAttrs.version;
    hash = "sha256-KRQZKP3i7EKidUejk3iw/Jh6Dpcp0NJZmRXCStMAtCM=";
  };

  postPatch = ''
    # link dynamically
    substituteInPlace Makefile --replace-fail \
      'LIBTLS_LDFLAGS_STATIC = -ltls -lssl -lcrypto -static' \
      'LIBTLS_LDFLAGS_STATIC = -ltls -lssl -lcrypto'
  '';

  buildInputs = [
    libressl
  ];

  makeFlags = [
    "RANLIB:=$(RANLIB)"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 youtube/cgi $out/bin/youtube-cgi
    install -Dm755 youtube/gopher $out/bin/youtube-gopher
    install -Dm755 youtube/cli $out/bin/youtube-cli

    runHook postInstall
  '';

  passthru = {
    v0_6 = finalAttrs.finalPackage.overrideAttrs (_: rec {
      version = "0.6";
      src = fetchgit {
        url = "git://git.codemadness.org/frontends";
        rev = version;
        hash = "sha256-VDHUY9xb6WyVQ/PcEJuo1HQTW1oox9yvVq0Xd7OGAt0=";
      };
    });
  };

  meta = with lib; {
    platforms = platforms.linux;
    description = "A less resource-heavy Youtube interface";
    maintainers = with maintainers; [ colinsane ];
    homepage = "https://codemadness.org/idiotbox.html";
    license = licenses.isc;
  };
})

