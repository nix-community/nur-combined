{
  lib,
  stdenv,
  kernel,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "alx-wol";
  version = kernel.version;

  src = fetchFromGitHub {
    owner = "Ev357";
    repo = "alx-wol";
    rev = "583a78a44473bc67d37fc544008e16371fe04772";
    sha256 = "sha256-Kuefu1PkABhXC77eoKl3UpLqet2eVHGRD1dvUICJdW4=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase =
    # bash
    ''
      make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD modules
    '';

  installPhase =
    # bash
    ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
      cp alx.ko $out/lib/modules/${kernel.modDirVersion}/extra/
    '';

  meta = {
    description = "Atheros ALX Wake-on-LAN kernel module patch";
    homepage = "https://github.com/Ev357/alx-wol";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
