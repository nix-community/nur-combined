{
  name = "ublksrv";
  meta.timeout = 300;

  nodes = {
    open =
      { ... }:
      {
        programs.ublksrv.enable = true;

        users.users.alice = {
          isNormalUser = true;
        };
      };

    restricted =
      { ... }:
      {
        programs.ublksrv = {
          enable = true;
          unprivileged.group = "ublk";
        };

        users.users.alice = {
          isNormalUser = true;
          extraGroups = [ "ublk" ];
        };
        users.users.bob = {
          isNormalUser = true;
        };
      };
  };

  testScript = ''
    import re

    def as_user(machine, user, cmd):
        return machine.succeed(f"su - {user} -c {cmd!r}")

    # The null/nfs/iscsi targets refuse unprivileged devices upstream, so use
    # a loop device backed by a file the user owns.
    def add_dev(machine, user):
        as_user(machine, user, "truncate -s 16M ~/disk.img")
        out = as_user(machine, user, "ublk add -t loop -f ~/disk.img --buffered_io --unprivileged")
        m = re.search(r"dev id (\d+):", out)
        assert m, f"unexpected output from ublk add: {out}"
        dev = int(m.group(1))
        machine.wait_until_succeeds(f"test -b /dev/ublkb{dev}")
        return dev

    start_all()
    open.wait_for_unit("multi-user.target")
    restricted.wait_for_unit("multi-user.target")

    with subtest("ublk_drv is loaded and control node is world accessible"):
        open.succeed("grep -q '^ublk_drv ' /proc/modules")
        open.succeed("test -c /dev/ublk-control")
        assert open.succeed("stat -c %a /dev/ublk-control").strip() == "666"

    with subtest("unprivileged user can create and use a ublk device"):
        dev = add_dev(open, "alice")
        for node in [f"/dev/ublkb{dev}", f"/dev/ublkc{dev}"]:
            open.wait_until_succeeds(f"test \"$(stat -c %U {node})\" = alice")
        as_user(open, "alice", f"ublk list -n {dev} | grep -q 'owner: 1000:'")
        as_user(open, "alice", f"echo hello-ublk | dd of=/dev/ublkb{dev} conv=fsync status=none")
        as_user(open, "alice", f"dd if=/dev/ublkb{dev} bs=512 count=1 status=none | grep -q hello-ublk")
        as_user(open, "alice", "grep -q hello-ublk ~/disk.img")
        as_user(open, "alice", f"ublk del -n {dev}")
        open.wait_until_fails(f"test -e /dev/ublkb{dev}")

    with subtest("root can still create privileged devices"):
        open.succeed("ublk add -t null -n 7")
        open.wait_until_succeeds("test -b /dev/ublkb7")
        assert open.succeed("stat -c %U /dev/ublkb7").strip() == "root"
        open.succeed("ublk del -n 7")

    with subtest("group-restricted control node"):
        assert restricted.succeed("stat -c '%a %G' /dev/ublk-control").strip() == "660 ublk"
        restricted.fail("su - bob -c 'truncate -s 16M ~/disk.img && ublk add -t loop -f ~/disk.img --unprivileged'")
        dev = add_dev(restricted, "alice")
        restricted.wait_until_succeeds(f"test \"$(stat -c %U /dev/ublkb{dev})\" = alice")
        as_user(restricted, "alice", f"ublk del -n {dev}")
  '';
}
