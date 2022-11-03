{ lib
, resholve
, fetchzip
, bash
, coreutils
, OVMF
, qemu
, rp ? ""
}:

resholve.mkDerivation rec {
  pname = "run_archiso";
  version = "68";

  src = fetchzip {
    url = "${rp}https://gitlab.archlinux.org/archlinux/archiso/-/archive/v${version}/archiso-v${version}.zip";
    hash = "sha256-xQ6CLaktfeUx/fdNmXDWVMWZ1zAh8KSzLHMisUe6ml0=";
  };

  postPatch = ''
    substituteInPlace scripts/run_archiso.sh \
      --replace "cp -av" "cp -v --no-preserve=mode" \
      --replace "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd" ${OVMF.variables} \
      --replace "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd" ${OVMF.firmware} \
      --replace "/usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.fd" ${(OVMF.override {
        secureBoot = true;
      }).firmware}
  '';

  dontBuild = true;

  installPhase = ''
    install -Dm555 scripts/run_archiso.sh $out/bin/run_archiso
  '';

  solutions.profile = {
    scripts = [ "bin/run_archiso" ];
    interpreter = [ "${bash}/bin/bash" ];
    inputs = [ coreutils qemu ];
    execer = [ "cannot:${qemu}/bin/qemu-system-x86_64" ];
  };

  meta = with lib; {
    description = "Script to run ISO images with qemu";
    homepage = "https://gitlab.archlinux.org/archlinux/archiso";
    license = licenses.gpl3Plus;
  };
}