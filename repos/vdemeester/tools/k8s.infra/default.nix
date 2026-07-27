{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "k8s.infra";
  src = ./.;
  phases = [ "installPhase" "fixupPhase" ];
  buildInputs = with pkgs; [
    makeWrapper
  ];
  installPhase = ''
    mkdir -p $out $out/bin
    cp $src/k8s.infra.sh $out/bin/k8s.infra

    wrapProgram "$out/bin/k8s.infra" --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nixos-generators pkgs.virtmanager pkgs.libguestfs-with-appliance pkgs.qemu pkgs.libvirt ]}
  '';
}
