# you can choose from a list here:
# https://www.sphinx-doc.org/en/master/man/sphinx-build.html
{ sphinx-doc-type ? "html" }:
{ stdenvNoCC, lib, ceph, python3Packages, doxygen, ditaa }:

# more info https://readthedocs.org/projects/ceph/builds/13596191/

stdenvNoCC.mkDerivation {
  pname = "ceph-doc-${sphinx-doc-type}" ;
  version = ceph.version;

  src = ceph.src;

  nativeBuildInputs = [
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.pillow
    python3Packages.cython
    python3Packages.wheel
    python3Packages.sphinx
    python3Packages.pyyaml
    ceph
    doxygen
    # this is for offline building of diagrams. otherwise
    # it tries to connect to the internet.
    ditaa
  ];

  buildPhase = ''
    runHook preBuild

    cd doc

    python -m sphinx -T -E -b ${sphinx-doc-type} -d _build/doctrees -D language=en . _build/docs

    runHook postBuild
  '';

  meta = with lib; {
    inherit (ceph.meta) homepage license;
    description = "Ceph documentation in ${sphinx-doc-type} format";
    broken = true;
  };
}
