{
  apt,
  autoreconfHook,
  dpkg,
  fetchFromGitLab,
  groff,
  hostname,
  iproute2,
  lib,
  makeWrapper,
  mmdebstrap,
  perl,
  perlPackages,
  stdenv,
  system-sendmail,
  man-db,
  shadow,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sbuild";
  version = "0.91.9_bpo13+1";

  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "debian";
    repo = "sbuild";
    rev = "debian/${finalAttrs.version}";
    hash = "sha256-udehTT9PxqNHOVDWbePfmINkEUn0202urcCT1mSf1W8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    dpkg
    groff
    perl
    perlPackages.FilesysDf
    makeWrapper
  ];

  postPatch = ''
    substituteInPlace bin/* tools/* \
      --replace-quiet /usr/bin/perl ${lib.getExe perl}
    substituteInPlace lib/Buildd.pm \
      --replace-fail /bin/hostname ${lib.getExe hostname}
    substituteInPlace bin/check-old-builds \
      --replace-fail /usr/sbin/sendmail ${lib.getExe system-sendmail}
    substituteInPlace etc/Makefile.am man/Makefile.am \
      --replace-fail PERL5LIB= 'PERL5LIB=$(PERL5LIB):'
    substituteInPlace lib/Sbuild.pm \
      --replace-fail "system('man', '--', \$section, \$page);" \
        "system('${lib.getExe man-db}', \"$out/share/man/man\$section/\$page.\$section.gz\");"
    substituteInPlace lib/Sbuild/ChrootUnshare.pm \
      --replace-fail '/usr/libexec' "$out/libexec" \
      --replace-fail '/usr/sbin/groupadd' '${lib.getExe' shadow "groupadd"}' \
      --replace-fail '/usr/sbin/useradd' '${lib.getExe' shadow "useradd"}'
    substituteInPlace lib/Sbuild/Conf.pm \
      --replace-fail "DEFAULT => 'mmdebstrap'" "DEFAULT => '${lib.getExe mmdebstrap}'"
  '';

  postInstall = ''
    pushd ${lib.getDev stdenv.cc.libc}/include
    for h in syscall.h sys/ioctl.h $(cc -M syscall.h sys/ioctl.h | \
        sed -n 's:^\s\+${lib.getDev stdenv.cc.libc}/include/\(\S\+\)\s*\\\?$:\1:p' | \
        sort -u); do
      h2ph -d $out/share/perl5 "$h"
    done
    popd
    for f in $out/bin/* $out/libexec/*; do
      test -f $f && wrapProgram $f \
        --prefix PERL5LIB : "$out/share/perl5:${
          perlPackages.makePerlPath [
            dpkg
            perlPackages.ClassDataInheritable
            perlPackages.DevelStackTrace
            perlPackages.ExceptionClass
            perlPackages.FilesysDf
            perlPackages.MIMELite
            perlPackages.YAMLTiny
          ]
        }" \
        --prefix PATH : "/run/wrappers/bin:${
          lib.makeBinPath [
            apt
            dpkg
            hostname
            iproute2
          ]
        }"
    done
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    version = builtins.replaceStrings [ "_" ] [ "~" ] finalAttrs.version;
  };

  meta = {
    description = "Tool for building Debian binary packages from Debian sources";
    homepage = "https://salsa.debian.org/debian/sbuild";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
    mainProgram = "sbuild";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
