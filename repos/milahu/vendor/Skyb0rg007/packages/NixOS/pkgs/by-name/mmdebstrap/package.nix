{
  lib,
  fetchFromForgejo,
  stdenv,
  installShellFiles,
  perl,
  perlPackages,
  python3,
  makeWrapper,
  dpkg,
  apt,
  debian-archive-keyring,
  help2man,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mmdebstrap";
  version = "1.5.7";

  src = fetchFromForgejo {
    domain = "gitlab.mister-muffin.de";
    owner = "josch";
    repo = "mmdebstrap";
    tag = finalAttrs.version;
    hash = "sha256-P0S2FHKR2gKtj47xyB7wOZZV5K8p9uLGvJ5tlmgCtdc=";
  };

  nativeBuildInputs = [
    installShellFiles
    perl
    python3
    makeWrapper
    help2man
  ];

  buildInputs = [
    perl
    python3
  ];

  postPatch = ''
        python3 - << 'PYTHON'
    with open('mmdebstrap') as f:
        src = f.read()

    old = '    print $conf "Dir \\"$options->{root}\\";\\n";\n'
    add = (
        '    print $conf "Dir::State \\"var/lib/apt\\";\\n";\n'
        '    print $conf "Dir::Cache \\"var/cache/apt\\";\\n";\n'
        '    print $conf "Dir::Etc \\"etc/apt\\";\\n";\n'
        '    print $conf "Dir::Log \\"var/log/apt\\";\\n";\n'
    )
    assert old in src, repr(old) + ' not found in mmdebstrap source'
    src = src.replace(old, old + add, 1)

    with open('mmdebstrap', 'w') as f:
        f.write(src)
    PYTHON
  '';

  buildPhase = ''
    runHook preBuild

    mv tarfilter mmtarfilter
    patchShebangs mmtarfilter

    pod2man mmdebstrap > mmdebstrap.1
    pod2man mmdebstrap-autopkgtest-build-qemu > mmdebstrap-autopkgtest-build-qemu.1
    help2man --no-info --name "filter a tarball like dpkg does" \
      --version-string="${finalAttrs.version}" ./mmtarfilter > ./mmtarfilter.1

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installBin mmdebstrap mmtarfilter mmdebstrap-autopkgtest-build-qemu

    mkdir -p $out/lib/apt/solvers
    cp -a proxysolver $out/lib/apt/solvers

    mkdir -p $out/share/mmdebstrap
    cp -a hooks $out/share/mmdebstrap

    mkdir -p $out/libexec/mmdebstrap
    cp -a gpgvnoexpkeysig $out/libexec/mmdebstrap
    cp -a ldconfig.fakechroot $out/libexec/mmdebstrap

    mkdir -p $out/share/perl5

    pushd ${lib.getDev stdenv.cc.libc}/include
    for h in syscall.h sys/ioctl.h $(cc -M syscall.h sys/ioctl.h | \
        sed -n 's:^\s\+${lib.getDev stdenv.cc.libc}/include/\(\S\+\)\s*\\\?$:\1:p' | \
        sort -u); do
      h2ph -d $out/share/perl5 "$h"
    done
    popd

    wrapProgram $out/bin/mmdebstrap \
      --prefix PERL5LIB : "$out/share/perl5" \
      --prefix PATH : "${
        lib.makeBinPath [
          apt
          dpkg
        ]
      }" \
      --run '_mm_tmp=$(mktemp -d); touch "$_mm_tmp/dpkg-status"; printf "Dir::State::Status \"%s/dpkg-status\";\nDir::Etc::TrustedParts \"${debian-archive-keyring}/etc/apt/trusted.gpg.d\";\n" "$_mm_tmp" > "$_mm_tmp/apt.conf"; export APT_CONFIG="$_mm_tmp/apt.conf"'

    wrapProgram $out/bin/mmdebstrap-autopkgtest-build-qemu \
      --prefix PATH : "${lib.getBin dpkg}/bin"

    installManPage \
      mmdebstrap.1 \
      mmdebstrap-autopkgtest-build-qemu.1

    runHook postInstall
  '';

  meta = {
    description = "";
    homepage = "https://gitlab.mister-muffin.de/josch/mmdebstrap/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "mmdebstrap";
  };
})
