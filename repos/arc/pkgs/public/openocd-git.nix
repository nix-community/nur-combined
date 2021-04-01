{
  openocd
, fetchgit, autoreconfHook, lib
, git, jimtcl-minimal ? null, libjaylink ? null, enableJaylink ? libjaylink != null
}: with lib; openocd.overrideAttrs (old: rec {
  pname = "openocd-git";
  name = "openocd-git-${version}";
  version = "2021-01-13";

  patches = [ ];

  nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook git jimtcl-minimal ];
  buildInputs = old.buildInputs
    ++ optional enableJaylink libjaylink
    ++ optional (jimtcl-minimal != null) jimtcl-minimal;
  configureFlags = filter (f: !hasSuffix "oocd_trace" f) old.configureFlags
    ++ optional (jimtcl-minimal != null) "--disable-internal-jimtcl"
    ++ optional (!enableJaylink || libjaylink != null) "--disable-internal-libjaylink";

  enableParallelBuilding = true;
  NIX_LDFLAGS = optional (jimtcl-minimal != null) "-lreadline";

  src = fetchgit ({
    url = "https://repo.or.cz/r/openocd.git";
    rev = "aaa6110d9b027acd1d027ef27c723ec9cf2381a0";
    sha256 = "048vl18p65yjjkb6b97fskx9fwy2bgm5vnkpv56p1zp0prqr7icz";
  } // optionalAttrs (jimtcl-minimal == null || (enableJaylink && libjaylink == null)) {
    fetchSubmodules = true;
    sha256 = "048vl18p65yjjkb6b97fskx9fwy2bgm5vnkpv56p1zp0prqr7icz";
  });

  meta = old.meta or {} // {
    broken = old.meta.broken or false || openocd.stdenv.isDarwin;
  };
})
