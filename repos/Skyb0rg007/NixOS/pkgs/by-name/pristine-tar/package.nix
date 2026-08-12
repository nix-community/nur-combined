{
  lib,
  fetchFromGitLab,
  stdenv,
  perl,
  perlPackages,
  zlib,
  makeWrapper,
  git,
  shunit2,
  xdelta,
  which,
  diffoscope,
  pbzip2,
  pixz,
  xz,
  bzip2,
  gzip,
  gnutar,
  coreutils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pristine-tar";
  version = "1.49";
  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "debian";
    repo = "pristine-tar";
    tag = finalAttrs.version;
    hash = "sha256-BSqBe6jHUwHxt+jc4UuWrpL2BfSGv+a0+N9lcV6hf3w=";
  };

  nativeBuildInputs = [
    perl
    makeWrapper
  ];

  buildInputs = [
    zlib
  ];

  nativeCheckInputs = [
    shunit2
    xdelta
    git
    which
    diffoscope
    pbzip2
    pixz
    xz
    bzip2
    gzip
    perlPackages.SysCpuAffinity
  ];

  postPatch = ''
    # setUp() overwrites TMPDIR with a directory that tearDown() then deletes,
    # so every mktemp after the first test resolves against a missing parent.
    # The tearDown() guard matters when a test file has no tests left: shunit2
    # still runs tearDown once, with TMPDIR untouched, and would otherwise wipe
    # the base directory out from under every later test file.
    substituteInPlace test/helper.sh \
      --replace-fail 'TMPDIR=$(mktemp -d)' 'TMPDIR=$(mktemp -d -p "$BASETMPDIR")' \
      --replace-fail 'rm -rf "$TMPDIR"' \
        '[ "$TMPDIR" = "$BASETMPDIR" ] || rm -rf "$TMPDIR"' \
      --replace-fail 'export PERL5LIB="$SRCDIR/blib/lib"' \
        'export PERL5LIB="$SRCDIR/blib/lib''${PERL5LIB:+:$PERL5LIB}"'
    sed -i '/^setUp() {/i BASETMPDIR="''${TMPDIR:-/tmp}"\n' test/helper.sh

    # Reading deltas in the pre-xdelta3 formats (v2, v2.0, v3.0) needs xdelta
    # v1, which nixpkgs does not carry. Drop those cases; what is left still
    # covers the formats pristine-tar generates today. test_1_33.sh goes
    # entirely -- it is nothing but backwards-compatibility cases -- and it has
    # to be deleted rather than emptied, see the tearDown() note above.
    rm test/test_1_33.sh
    substituteInPlace test/test_deltas.sh \
      --replace-fail 'test_tar_2() {' 'skipped_test_tar_2() {' \
      --replace-fail 'test_tar_2_0() {' 'skipped_test_tar_2_0() {' \
      --replace-fail 'test_bz2_2_0() {' 'skipped_test_bz2_2_0() {' \
      --replace-fail 'test_gz_2_0() {' 'skipped_test_gz_2_0() {' \
      --replace-fail 'test_gz_3_0() {' 'skipped_test_gz_3_0() {' \
      --replace-fail 'test_xz_2_0() {' 'skipped_test_xz_2_0() {'
    substituteInPlace test/test_verify.sh \
      --replace-fail 'test_verify_without_stored_hash() {' \
        'skipped_test_verify_without_stored_hash() {'

    # xz >= 5.4 always records the compressed/uncompressed sizes in the block
    # header, so pristine-xz can no longer byte-for-byte reproduce the .xz
    # samples (which were generated with xz < 5.4). Nothing here can fix that
    # short of shipping an obsolete xz, so drop the affected cases.
    substituteInPlace test/test_roundtrip.sh \
      --replace-fail 'test_xz() {' 'skipped_test_xz() {'
    substituteInPlace test/test_bugs.sh \
      --replace-fail 'test_851286() {' 'skipped_test_851286() {'
  '';

  configurePhase = ''
    runHook preConfigure

    perl Makefile.PL PREFIX=$out INSTALLDIRS=site

    runHook postConfigure
  '';

  postFixup = ''
    for prog in pristine-bz2 pristine-gz pristine-tar pristine-xz; do
      wrapProgram $out/bin/$prog --inherit-argv0 \
        --prefix PERL5LIB : "$out/lib/perl5/site_perl:${
          perlPackages.makePerlPath [ perlPackages.SysCpuAffinity ]
        }" \
        --prefix PATH : "$out/bin:${
          lib.makeBinPath [
            git
            gnutar
            coreutils
            xdelta
            xz
            pixz
            bzip2
            pbzip2
            gzip
          ]
        }"
    done
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    perl test.pl

    runHook postCheck
  '';

  meta = {
    homepage = "https://salsa.debian.org/debian/pristine-tar";
    license = lib.licenses.AND [
      lib.licenses.bsd3
      lib.licenses.bzip2
      lib.licenses.gpl2Plus
    ];
    platforms = lib.platforms.linux;
    mainProgram = "pristine-tar";
  };
})
