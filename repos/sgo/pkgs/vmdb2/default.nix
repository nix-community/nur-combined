{ lib, stdenv, fetchgit, pkgs, parted, debootstrap, python3, python3Packages, cmdtest, pandoc, qemu, multipath-tools }:

python3.pkgs.buildPythonApplication rec {
  pname = "vmdb2";
  version = "0.13.2+git20191226-4";

  src = fetchgit {
    url = "git://git.liw.fi/vmdb2";
    rev = "89cfdef45f37a8d57bce71a62be8246ea3f895e9";
    sha256 = "0qqswip2jzpqmzg9bf2csq5plw3x9rklwn1rxsp2id5psd8l6m7n";
  };

  postPatch = ''
    substituteInPlace vmdb/plugins/mkfs_plugin.py --replace "/sbin/mkfs" "mkfs"
  '';

  nativeBuildInputs = [
    pandoc
  ];

  propagatedBuildInputs =  [
    cmdtest
    debootstrap
    parted
    python3
    qemu
    multipath-tools
  ];

  doCheck=false;

}
