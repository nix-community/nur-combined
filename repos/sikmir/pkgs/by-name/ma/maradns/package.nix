{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maradns";
  version = "2026-07-05";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "samboy";
    repo = "MaraDNS";
    tag = finalAttrs.version;
    hash = "sha256-43TWaaua4zQBXU72vKQF6WY41h+mpa40bhHhDL3CExM=";
  };

  postPatch = ''
    substituteInPlace configure --replace-fail '"maradns"' '"source"'
  '';

  configurePhase = ''
    echo VERSION=${finalAttrs.version} > VERSION
    ./configure
  '';

  preInstall = ''
    mkdir -p $out/share/man/man{1,5,8}
  '';

  dontCheckForBrokenSymlinks = true;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A small open-source DNS server";
    homepage = "https://github.com/samboy/MaraDNS";
    license = with lib.licenses; [
      bsd2
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
