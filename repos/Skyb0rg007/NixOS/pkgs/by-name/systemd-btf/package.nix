{
  lib,
  nixpkgs,
}:
nixpkgs.systemd.overrideAttrs (prevAttrs: {
  pname = "${prevAttrs.pname}-btf";

  postPatch = (prevAttrs.postPatch or "") + ''
    install -m444 ${./vmlinux.h} src/bpf/vmlinux.h
  '';

  preConfigure = (prevAttrs.preConfigure or "") + ''
    appendToVar mesonFlags "-Dvmlinux-h-path=$PWD/src/bpf/vmlinux.h"
  '';

  mesonFlags = (prevAttrs.mesonFlags or [ ]) ++ [
    (lib.mesonOption "vmlinux-h" "provided")
  ];
})
