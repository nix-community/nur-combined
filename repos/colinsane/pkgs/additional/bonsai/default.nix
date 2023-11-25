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
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~stacyharper";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-jOtFUpl2/Aa7f8JMZf6g63ayFOi+Ci+i7Ac63k63znc=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'hare build' 'hare build $(HARE_TARGET_FLAGS)'
  '';

  env.HARE_TARGET_FLAGS =
    if stdenv.hostPlatform.isAarch64 then
      "-t aarch64"
    else if stdenv.hostPlatform.isRiscV64 then
      "-t riscv64"
    else if stdenv.hostPlatform.isx86_64 then
      "-t x86_64"
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

  # NOTE: bonsaid 1.0.2 requires newer hare than exists in nixpkgs as of 2023/11.
  # passthru.updateScript = gitUpdater {
  #   rev-prefix = "v";
  # };

  meta = with lib; {
    description = "Bonsai is a Finite State Machine structured as a tree";
    homepage = "https://git.sr.ht/~stacyharper/bonsai";
    license = licenses.agpl3;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
