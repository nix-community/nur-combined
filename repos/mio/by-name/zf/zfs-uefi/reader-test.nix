{
  runNixOSTest,
  nativeReader,
}:

# Boots a NixOS VM with ZFS, creates a real pool there, and runs the reader
# natively against a copy of the pool image.  This is the only way to check the
# reader on this repository's machines: creating a pool needs root and the ZFS
# module, which the build host does not have.
#
# Two images are checked:
#   * tank/win, an ordinary dataset with the Windows-like tree the upstream
#     test looks up, in a pool that also carries the com.datto:encryption
#     feature;
#   * tank/enc, an encrypted dataset, which the reader must mount and read as
#     plaintext once its key is loaded (the test reads /hello.txt, written as
#     "secret"), and refuse with its explicit message when no key is given.
#
# The encrypted legs are the real check of the decryption path: the key store
# unwraps the dataset key, then block decryption has to return the file's text.
runNixOSTest {
  name = "zfs-uefi-reader";

  nodes.machine =
    { pkgs, ... }:
    {
      # ZFS needs a host ID, and the module has to be available for zpool to
      # create pools.
      networking.hostId = "8425e349";
      boot.supportedFilesystems = [ "zfs" ];

      virtualisation = {
        memorySize = 3072;
        cores = 2;
      };

      environment.systemPackages = [
        pkgs.zfs
        pkgs.util-linux
        nativeReader
      ];
    };

  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")

    # The pool goes on a loop device, not on the image file itself: the reader
    # only accepts disk, mirror and raidz vdevs and rejects a file vdev at
    # probe time.  The backing file is what the reader is pointed at.
    machine.succeed("truncate -s 1G /root/tank.img")
    machine.succeed("losetup /dev/loop0 /root/tank.img")
    machine.succeed(
        "zpool create -f -O casesensitivity=insensitive -O atime=off "
        "-O compression=off tank /dev/loop0"
    )

    # The tree test/native_read_test.c expects: hello.txt at the root, and 402
    # entries in Windows/System32 (400 File*.Dll, ntoskrnl.exe and CONFIG).
    machine.succeed("zfs create tank/win")
    machine.succeed("echo hello > /tank/win/hello.txt")
    machine.succeed("mkdir -p /tank/win/Windows/System32/CONFIG")
    machine.succeed(
        "for i in $(seq 1 400); do "
        ": > /tank/win/Windows/System32/$(printf 'File%04d.Dll' $i); done"
    )
    machine.succeed("echo fake > /tank/win/Windows/System32/ntoskrnl.exe")
    machine.succeed("echo system > /tank/win/Windows/System32/CONFIG/system")
    machine.succeed("zpool set bootfs=tank/win tank")

    # Enabling encryption on the pool is what the plain dataset must survive.
    # A raw key in a file is used rather than a passphrase because the
    # passphrase prompts of zfs create and zfs load-key read /dev/tty, which
    # does not exist here; the blocks this reader sees are encrypted either
    # way.
    machine.succeed("head -c 32 /dev/urandom > /root/zfs.key")
    machine.succeed(
        "zfs create -o encryption=on -o keyformat=raw "
        "-o keylocation=file:///root/zfs.key tank/enc"
    )
    machine.succeed("echo secret > /tank/enc/hello.txt")
    machine.succeed("sync")

    print(machine.succeed("zfs get -H casesensitivity tank/win"))
    print(machine.succeed("zpool get -H feature@com.datto:encryption tank"))

    # The reader is pointed at the loop device itself, with the pool exported:
    # there is no copy to go stale, and only one image to keep straight.
    # bootfs=tank/win for this run.
    machine.succeed("zpool export tank")
    status, out = machine.execute("native_read_test /dev/loop0 0 1073741824")
    print(out)
    assert status == 0, "reader failed on the unencrypted dataset"
    assert "ALL PASSED" in out, out

    # bootfs=tank/enc; the export unloaded its key, as on a machine that has
    # just been powered on.
    machine.succeed("zpool import -d /dev tank")
    machine.succeed("zpool set bootfs=tank/enc tank")
    machine.succeed("zpool export tank")

    # The key store and the read path: with the right raw keyfile the reader
    # must unwrap the dataset key, mount the dataset and return the file's
    # text, which was written as plaintext and is ciphertext on disk.
    status, out = machine.execute(
        "ZFS_KEY_FILE=/root/zfs.key enc_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert status == 0, out
    assert "dataset key loaded: aes-256-gcm" in out, out
    assert "unwrap failed" not in out, out
    assert "mount rc 0" in out, out
    assert "hello.txt: 'secret'" in out, out

    # Any other 32 bytes must fail the tag check rather than be accepted.
    machine.succeed("head -c 32 /dev/urandom > /root/bad.key")
    status, out = machine.execute(
        "ZFS_KEY_FILE=/root/bad.key enc_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert "dataset key unwrap failed" in out, out
    assert "dataset key loaded" not in out, out
    assert "mount rc 0" not in out, out

    # Passphrase dataset: the key object carries keyformat/pbkdf2salt/
    # pbkdf2iters, so the reader derives the wrapping key from what is typed
    # instead of being handed one.  This is the boot-time prompt path.
    machine.succeed("zpool import -d /dev tank")
    machine.succeed(
        "printf 'correct horse battery staple\\n' > /root/pass.txt"
    )
    machine.succeed(
        "zfs create -o encryption=on -o keyformat=passphrase "
        "-o keylocation=file:///root/pass.txt tank/phrase"
    )
    machine.succeed("echo passphrase > /tank/phrase/hello.txt")
    print(machine.succeed(
        "zfs get -H -o property,value keyformat,encryption tank/phrase"
    ))
    machine.succeed("sync")
    machine.succeed("zpool set bootfs=tank/phrase tank")

    machine.succeed("zpool export tank")
    status, out = machine.execute(
        "ZFS_PASSPHRASE='correct horse battery staple' "
        "enc_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert status == 0, out
    assert "dataset key loaded: aes-256-gcm" in out, out
    assert "mount rc 0" in out, out
    assert "hello.txt: 'passphrase'" in out, out

    # A wrong passphrase must be rejected, and the first wrong entry followed
    # by the right one must re-prompt and then succeed.
    status, out = machine.execute(
        "ZFS_PASSPHRASE='wrong passphrase' "
        "enc_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert "dataset key unwrap failed" in out, out
    assert "dataset key loaded" not in out, out

    status, out = machine.execute(
        "ZFS_PASSPHRASE_FIRST_WRONG=1 "
        "ZFS_PASSPHRASE='correct horse battery staple' "
        "enc_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert "wrong passphrase/key, try again" in out, out
    assert "dataset key loaded: aes-256-gcm" in out, out
    assert "hello.txt: 'passphrase'" in out, out

    # And the plain-text reader must still refuse encrypted blocks explicitly
    # when it has no key at all.
    status, out = machine.execute(
        "native_read_test /dev/loop0 0 1073741824"
    )
    print(out)
    assert "encrypted block read before the dataset key was loaded" in out, out
    assert "mount rc 0" not in out, out
    assert "ALL PASSED" not in out, out
  '';
}
