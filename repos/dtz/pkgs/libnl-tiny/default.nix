{ stdenv, lib, fetchgit, cmake }:

stdenv.mkDerivation rec {
  pname = "libnl-tiny";
  version = "2019-10-29";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "0219008cc8767655d7e747497e8e1133a3e8f840";
    sha256 = "1bwl45jpyr774m11ksa2bhj4x4ikz13jrg12pdal1zxfjwahnlkq";
  };

  nativeBuildInputs = [ cmake ];

  patches = [ ./use-cmake-install-full-dirs.patch ];

  postInstall = ''
    install -Dt $out/lib/pkgconfig *.pc
  '';

  meta = with lib; {
    description = "Stripped-down version of libnl";
    homepage = "https://git.openwrt.org/?p=project/libnl-tiny.git;a=summary";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ dtzWill ];
  };
}
