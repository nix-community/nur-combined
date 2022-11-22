# boot.initrd.prepend = with pkgs.nur.repos.dukzcry; [
#   ''
#     ${dsdt {
#       src = /etc/nixos/dsdt.aml;
#       patches = [
#         ./patch-mic
#       ];
#     }}/dsdt
#   ''
# ];

{ stdenvNoCC, lib, acpica-tools, cpio
, src
, patches ? []
}:

stdenvNoCC.mkDerivation rec {
  name = "dsdt";

  inherit src patches;

  nativeBuildInputs = [ acpica-tools cpio ];

  unpackCmd = ''
    mkdir out
    iasl -p out/dsdt -d ${src}
  '';

  buildPhase = ''
    iasl -tc dsdt.dsl
  '';

  installPhase = ''
    mkdir -p kernel/firmware/acpi
    cp dsdt.aml kernel/firmware/acpi
    mkdir $out
    find kernel | cpio -H newc --create > $out/dsdt
  '';

  meta = with lib; {
    description = "Patch DSDT and create CPIO archive from it";
    license = licenses.free;
    homepage = "https://wiki.archlinux.org/title/DSDT";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    broken = patches == [];
  };
}
