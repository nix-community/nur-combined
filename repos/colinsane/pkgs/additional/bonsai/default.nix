{ stdenv
, lib
, fetchFromSourcehut
, gitUpdater
, hare
, hare-ev
, hare-json
}:

stdenv.mkDerivation rec {
  pname = "bonsai";
  version = "1.0.2";

  src = fetchFromSourcehut {
    owner = "~stacyharper";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Yosf07KUOQv4O5111tLGgI270g0KVGwzdTPtPOsTcP8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'hare build' 'hare build $(HARE_TARGET_FLAGS)'
  '';

  env.HARE_TARGET_FLAGS =
    if stdenv.hostPlatform.isAarch64 then
      "-a aarch64"
    else if stdenv.hostPlatform.isRiscV64 then
      "-a riscv64"
    else if stdenv.hostPlatform.isx86_64 then
      "-a x86_64"
    else
      "";

  nativeBuildInputs = [
    hare
    hare-ev
    hare-json
  ];

  preConfigure = ''
    export HARECACHE=$(mktemp -d)
    # FIX "ar: invalid option -- '/'" bug in older versions of hare.
    # should be safe to remove once updated past 2023/05/22-ish.
    # export ARFLAGS="-csr"
  '';

  installFlags = [ "PREFIX=$(out)" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Bonsai is a Finite State Machine structured as a tree";
    homepage = "https://git.sr.ht/~stacyharper/bonsai";
    license = licenses.agpl3;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
