{ stdenv, lib, buildGoPackage, fetchgit, libvirt, git, pkgconfig }:

buildGoPackage rec {
  name = "openshift-install-${version}";
  version = "0.16.1";
  rev = "v${version}";

  goPackagePath = "github.com/openshift/installer";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/openshift/installer.git";
    sha256 = "1gn6m8hw7q5mijrp4rz1pwpwra4dish70dbygm2ksl02zc51x83r";
  };

  patches = [ ./0001-Do-not-call-git.patch ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvirt git ];

  buildPhase = ''
    cd go/src/${goPackagePath}
    GITCOMMIT=${version} TAGS=libvirt hack/build.sh
  '';

  installPhase = ''
    mkdir -p $bin/bin
    cp -a bin/* "$bin/bin"
  '';

  meta = {
    description = "Install an OpenShift cluster";
    homepage = https://github.com/openshift/installer;
    license = lib.licenses.asl20;
  };
}
