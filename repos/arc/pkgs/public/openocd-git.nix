{
  openocd
, fetchgit, lib
, libtool, autoconf, automake, which
, git, jimtcl-minimal ? null, libjaylink ? null, enableJaylink ? libjaylink != null
}: with lib; openocd.overrideAttrs (old: rec {
  pname = "openocd-git";
  name = "openocd-git-${version}";
  version = "2021-03-24";

  patches = [ ];

  nativeBuildInputs = old.nativeBuildInputs ++ [ libtool autoconf automake which git jimtcl-minimal ];
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
    rev = "6405d35f324f767c2ab88da12a600cb8e6c25f0e";
    sha256 = "1xj0nbjgmamvl94h1hm4waanhhq58z4zc7hkqvqr0ymmhqi9m0m8";
  } // optionalAttrs (jimtcl-minimal == null || (enableJaylink && libjaylink == null)) {
    fetchSubmodules = true;
    sha256 = "048vl18p65yjjkb6b97fskx9fwy2bgm5vnkpv56p1zp0prqr7icz";
  });

  preConfigure = ''
    SKIP_SUBMODULE=y bash -x ./bootstrap
  '';

  meta = old.meta or {} // {
    broken = old.meta.broken or false || openocd.stdenv.isDarwin || lib.isNixpkgsUnstable or false;
  };
})
