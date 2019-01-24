{ stdenv, lib, buildGoPackage, fetchgit, libvirt, git, pkgconfig }:

buildGoPackage rec {
  name = "openshift-install-${version}";
  version = "0.9.1";
  rev = "v${version}";

  goPackagePath = "github.com/openshift/installer";

  src = fetchgit {
    inherit rev;
    leaveDotGit = true;
    url = "https://github.com/openshift/installer.git";
    sha256 = "0zjb1vzzbsf90hzc72ss2bbypiq1bs0v4ps9wyanlmzmqkg56lhd";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvirt git ];

  buildPhase = ''
    cd go/src/${goPackagePath}
    TAGS=libvirt hack/build.sh
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
