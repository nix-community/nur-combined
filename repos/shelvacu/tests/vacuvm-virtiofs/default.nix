# virtiofs behaviour of vacuvm shares, through the real vacu.qemuVMs units.
# The guest is a kernel + busybox initrd rather than NixOS, so it boots in
# seconds even nested inside a builder that is itself a VM (unlike
# tests/qemu-vm).
{ pkgs, ... }:
let
  rootDir = "/tmp/vt-root";
  plainDir = "/tmp/vt-plain";
  rawDir = "/tmp/vt-raw";

  kernel = pkgs.linuxPackages.kernel;
  modules = pkgs.makeModulesClosure {
    kernel = pkgs.aggregateModules [ kernel.modules ];
    firmware = pkgs.emptyDirectory;
    rootModules = [
      "virtio_pci"
      "virtiofs"
    ];
  };

  guestInit = pkgs.writeScript "init" ''
    #!${pkgs.busybox}/bin/sh
    export PATH=${pkgs.attr}/bin:${pkgs.busybox}/bin
    mount -t proc proc /proc
    mount -t sysfs sys /sys
    mount -t devtmpfs dev /dev
    ${pkgs.kmod}/bin/modprobe -d ${modules} -a virtio_pci virtiofs

    fail() {
      echo "$*" > /mnt/rootfs/guest-done
      sync
      poweroff -f
    }
    for t in rootfs plain raw; do
      mkdir -p /mnt/$t
      mount -t virtiofs $t /mnt/$t || fail "mount $t"
    done

    f=/mnt/rootfs/f
    touch $f
    for ns in security trusted user; do
      setfattr -n $ns.vt -v $ns-val $f || fail "set $ns.vt on rootfs"
      [ "$(getfattr --only-values -n $ns.vt $f)" = $ns-val ] || fail "read back $ns.vt"
    done
    [ "$(getfattr --only-values -n user.preset /mnt/rootfs/host-made)" = from-host ] \
      || fail "user.nested.user.preset not visible as user.preset"
    if getfattr -d -m - /mnt/rootfs/host-made | grep -q hostonly; then
      fail "unmapped host xattr visible to guest"
    fi

    touch /mnt/plain/f
    if setfattr -n user.vt -v x /mnt/plain/f 2>/dev/null; then
      fail "xattr set on share without xattr"
    fi

    touch /mnt/raw/f
    setfattr -n user.vt -v raw-val /mnt/raw/f || fail "set user.vt on raw share"

    echo ok > /mnt/rootfs/guest-done
    sync
    poweroff -f
  '';

  guestInitrd = pkgs.makeInitrd {
    contents = [
      {
        object = guestInit;
        symlink = "/init";
      }
    ];
  };
in
{
  name = "vacuvm-virtiofs";

  nodes.host = { vacuModules, ... }: {
    imports = [ vacuModules.qemu-vm ];
    vacu.qemuVMs.t = {
      tag = 2;
      inherit rootDir;
      autoStart = false;
      baseMem = 256;
      shares = {
        plain.source = plainDir;
        raw = {
          source = rawDir;
          xattr = true;
          xattrMap = null;
        };
      };
    };
    environment.systemPackages = [ pkgs.attr ];
    virtualisation.memorySize = 1024;
  };

  testScript = ''
    host.start()
    host.wait_for_unit("multi-user.target")

    # The qemu unit boots whatever the rootfs's system profile points at; give
    # it the busybox guest, as plain files since it resolves them inside rootDir.
    profile = "${rootDir}/nix/var/nix/profiles/system"
    host.succeed(
        f"mkdir -p {profile} ${plainDir} ${rawDir}",
        f"cp ${kernel}/bzImage {profile}/kernel",
        f"cp ${guestInitrd}/initrd {profile}/initrd",
        f"echo 'console=ttyS0 panic=-1' > {profile}/kernel-params",
        "touch ${rootDir}/host-made",
        "setfattr -n user.nested.user.preset -v from-host ${rootDir}/host-made",
        "setfattr -n user.hostonly -v x ${rootDir}/host-made",
    )

    host.systemctl("start vacuvm-t-qemu.service")
    host.wait_until_succeeds("test -e ${rootDir}/guest-done", timeout=300)
    result = host.succeed("cat ${rootDir}/guest-done").strip()
    assert result == "ok", f"guest: {result}"

    for ns in ["security", "trusted", "user"]:
        host.succeed(
            f"test \"$(getfattr --only-values -n user.nested.{ns}.vt ${rootDir}/f)\" = {ns}-val"
        )
    host.succeed("test \"$(getfattr --only-values -n user.vt ${rawDir}/f)\" = raw-val")
  '';
}
