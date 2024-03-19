{ writeShellApplication
, qemu
, fetchurl
, redoxImage
  ? fetchurl {
    url = "https://static.redox-os.org/releases/0.8.0/x86_64/redox_demo_x86_64_2022-11-23_638_harddrive.img";
    hash = "sha256-WJ9s/jfbAkRGpjkc6fiVlxpqbsx2uDWkhQysRJyNgDE=";
  }
}:
writeShellApplication {
  name = "redox-demo";

  runtimeInputs = [ qemu ];

  text = ''
    image=$(mktemp redox-demo.XXXXXX.img)
    cp ${redoxImage} "$image"
    SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-x86_64 -d cpu_reset,guest_errors -smp 4 -m 2048 \
      -chardev stdio,id=debug,signal=off,mux=on,"" -serial chardev:debug -mon chardev=debug \
      -machine q35 -device ich9-intel-hda -device hda-duplex -netdev user,id=net0 \
      -device e1000,netdev=net0 -device nec-usb-xhci,id=xhci -enable-kvm -cpu host \
      -drive "file=$image,format=raw"
    rm "$image"
'';

  meta = {
    description = "A transient redox OS instance within QEMU";
  };
}
