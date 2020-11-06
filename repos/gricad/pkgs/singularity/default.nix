{stdenv
, removeReferencesTo
, lib
, fetchFromGitHub
, utillinux
, openssl
, coreutils
, go
, which
, makeWrapper
, squashfsTools
, buildGoModule}:

with lib;

buildGoModule rec {
  pname = "singularity";
  version = "3.5.3";

  src = fetchFromGitHub {
    owner = "sylabs";
    repo = "singularity";
    rev = "v${version}";
    sha256 = "0n4mphf8q2mj9qi3lxdg8bm97lpf0c80y69nnps1mf0rk70bkbj0";
  };

  vendorSha256 = "0iak4cc78q6s5cg2ffh6jkyfqhkvnj2j42fbq7az9n1hsmmlkqhm";

  goPackagePath = "github.com/sylabs/singularity";
  goDeps = ./deps.nix;

  hardeningDisable = [ "fortify" ];

  buildInputs = [ openssl ];
  nativeBuildInputs = [ removeReferencesTo utillinux which makeWrapper ];
  propagatedBuildInputs = [ coreutils squashfsTools ];

  prePatch = ''
    substituteInPlace internal/pkg/build/files/copy.go \
      --replace /bin/cp ${coreutils}/bin/cp
  '';

  postConfigure = ''
    #cd go/src/github.com/sylabs/singularity
    echo ${version} > VERSION

    patchShebangs .
    sed -i 's|defaultPath := "[^"]*"|defaultPath := "${stdenv.lib.makeBinPath propagatedBuildInputs}"|' cmd/internal/cli/actions.go

    ./mconfig -V ${version} -p $out --localstatedir=/var --without-suid

    # Don't install SUID binaries
    sed -i 's/-m 4755/-m 755/g' builddir/Makefile

  '';

  buildPhase = ''
    cd builddir
    make
  '';

  installPhase = ''
    make install LOCALSTATEDIR=$out/var
    wrapProgram $out/bin/singularity --prefix PATH : ${stdenv.lib.makeBinPath propagatedBuildInputs}
  '';

  postFixup = ''
    find $out/ -type f -executable -exec remove-references-to -t ${go} '{}' + || true

    # These etc scripts shouldn't have their paths patched
    #cp ../e2e/actions/* $out/etc/singularity/actions/
  '';

  meta = with stdenv.lib; {
    homepage = http://www.sylabs.io/;
    description = "Application containers for linux";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = [ maintainers.jbedo ];
  };
}
