self: super:
let
  qemu-user = user_arch: super.qemu.override {
    smartcardSupport = false;
    spiceSupport = false;
    openGLSupport = false;
    virglSupport = false;
    vncSupport = false;
    gtkSupport = false;
    sdlSupport = false;
    pulseSupport = false;
    smbdSupport = false;
    seccompSupport = false;
    hostCpuTargets = ["${user_arch}-linux-user"];
  };
in
{
  qemu-user-arm = qemu-user "arm";
  qemu-user-x86 = qemu-user "x86_64";
  qemu-user-arm64 = qemu-user "aarch64";
  qemu-user-riscv32 = qemu-user "riscv32";
  qemu-user-riscv64 = qemu-user "riscv64";
}
