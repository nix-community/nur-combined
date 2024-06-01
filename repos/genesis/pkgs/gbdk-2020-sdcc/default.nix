{ lib
, stdenv
, fetchpatch
, fetchsvn
, autoconf
, bison
, boost
, flex
, gputils
, texinfo
, zlib
, withGputils ? false
, excludePorts ? [
    "ds390"
    "ds400"
    "mcs51"
    "pic14"
    "pic16"
    "r2k"
    "r3ka"
    "s08"
    "stm8"
    "tlcs90"
    "z180"
  ]
}:

assert lib.subtractLists [
  "ds390"
  "ds400"
  "gbz80"
  "hc08"
  "mcs51"
  "mos6502"
  "mos65c02"
  "pic14"
  "pic16"
  "r2k"
  "r3ka"
  "s08"
  "stm8"
  "tlcs90"
  "z80"
  "z180"
]
  excludePorts == [ ];

stdenv.mkDerivation (finalAttrs: {
  pname = "gbdk-2020-sdcc";
  version = "4.4.0";

  # see https://github.com/gbdk-2020/gbdk-2020-sdcc/blob/main/.github/workflows/sdcc_build.yml
  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/sdcc/code/trunk";
    rev = "14865";
    sha256 = "sha256-YndxbmX2gKh7z926UKDfXgErfaNgDwn8Fx6oEL2Tevo=";
  };

  patchFlags = [ "-p0" ];
  patches = [

    (fetchpatch {
      url = "https://github.com/gbdk-2020/gbdk-2020-sdcc/releases/download/patches/gbdk-4.3-nes_banked_nonbanked_no_overlay_locals_v8_combined.patch";
      sha256 = "sha256-aLxtpMs5aVgCiJmV6CzwJuTUh5zP98E+t3HW5VvlWzA=";
    })
  ];

  outputs = [ "out" "doc" "man" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoconf
    bison
    flex
  ];

  buildInputs = [
    boost
    texinfo
    zlib
  ] ++ lib.optionals withGputils [
    gputils
  ];

  configureFlags =
    let
      excludedPorts = excludePorts
        ++ (lib.optionals (!withGputils) [ "pic14" "pic16" ]);
    in
    map (f: "--disable-${f}-port") excludedPorts;

  preConfigure = ''
    if test -n "''${dontStrip-}"; then
      export STRIP=none
    fi

    cd sdcc
  '';

  meta = {
    homepage = "https://sdcc.sourceforge.net/";
    description = "Small Device C Compiler";
    longDescription = ''
      SDCC is a retargettable, optimizing ANSI - C compiler suite that targets
      the Intel MCS51 based microprocessors (8031, 8032, 8051, 8052, etc.),
      Maxim (formerly Dallas) DS80C390 variants, Freescale (formerly Motorola)
      HC08 based (hc08, s08) and Zilog Z80 based MCUs (z80, z180, gbz80, Rabbit
      2000/3000, Rabbit 3000A). Work is in progress on supporting the Microchip
      PIC16 and PIC18 targets. It can be retargeted for other microprocessors.
    '';
    license =
      if withGputils
      then lib.licenses.unfreeRedistributable
      else lib.licenses.gpl2Plus;
    mainProgram = "sdcc";
    maintainers = with lib.maintainers; [ bjornfor yorickvp ];
    platforms = lib.platforms.all;
  };
})
