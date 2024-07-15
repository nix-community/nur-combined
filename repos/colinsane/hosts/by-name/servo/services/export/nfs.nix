# docs:
# - <https://nixos.wiki/wiki/NFS>
# - <https://wiki.gentoo.org/wiki/Nfs-utils>
# system files:
# - /etc/exports
# system services:
# - nfs-server.service
# - nfs-idmapd.service
# - nfs-mountd.service
# - nfsdcld.service
# - rpc-statd.service
# - rpcbind.service
#
# TODO: force files to be 755, or 750.
# - could maybe be done with some mount option?

{ config, lib, ... }:
lib.mkIf false  #< TODO: remove nfs altogether! it's not exactly the most secure
{
  services.nfs.server.enable = true;

  # see which ports NFS uses with:
  # - `rpcinfo -p`
  sane.ports.ports."111" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.lan = true;
    description = "NFS server portmapper";
  };
  sane.ports.ports."2049" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.lan = true;
    description = "NFS server";
  };
  sane.ports.ports."4000" = {
    protocol = [ "udp" ];
    visibleTo.lan = true;
    description = "NFS server status daemon";
  };
  sane.ports.ports."4001" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.lan = true;
    description = "NFS server lock daemon";
  };
  sane.ports.ports."4002" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.lan = true;
    description = "NFS server mount daemon";
  };

  # NFS4 allows these to float, but NFS3 mandates specific ports, so fix them for backwards compat.
  services.nfs.server.lockdPort = 4001;
  services.nfs.server.mountdPort = 4002;
  services.nfs.server.statdPort = 4000;

  services.nfs.extraConfig = ''
    [nfsd]
    # XXX: NFS over UDP REQUIRES SPECIAL CONFIG TO AVOID DATA LOSS.
    # see `man 5 nfs`: "Using NFS over UDP on high-speed links".
    # it's actually just a general property of UDP over IPv4 (IPv6 fixes it).
    # both the client and the server should configure a shorter-than-default IPv4 fragment reassembly window to mitigate.
    # OTOH, tunneling NFS over Wireguard also bypasses this weakness, because a mis-assembled packet would not have a valid signature.
    udp=y

    [exports]
    # all export paths are relative to rootdir.
    # for NFSv4, the export with fsid=0 behaves as `/` publicly,
    # but NFSv3 implements no such feature.
    # using `rootdir` instead of relying on `fsid=0` allows consistent export paths regardless of NFS proto version
    rootdir=/var/export
  '';

  # format:
  #   fspoint	visibility(options)
  # options:
  # - see: <https://wiki.gentoo.org/wiki/Nfs-utils#Exports>
  # - see [man 5 exports](https://linux.die.net/man/5/exports)
  # - insecure:  require clients use src port > 1024
  # - rw, ro (default)
  # - async, sync (default)
  # - no_subtree_check (default), subtree_check: verify not just that files requested by the client live
  #     in the expected fs, but also that they live under whatever subdirectory of that fs is exported.
  # - no_root_squash, root_squash (default): map requests from uid 0 to user `nobody`.
  # - crossmnt:  reveal filesystems that are mounted under this endpoint
  # - fsid:  must be zero for the root export
  #   - fsid=root  is alias for fsid=0
  # - mountpoint[=/path]:  only export the directory if it's a mountpoint. used to avoid exporting failed mounts.
  # - all_squash: rewrite all client requests such that they come from anonuid/anongid
  #   - any files a user creates are owned by local anonuid/anongid.
  #   - users can read any local file which anonuid/anongid would be able to read.
  #   - users can't chown to/away from anonuid/anongid.
  #   - users can chmod files they own, to anything (making them unreadable to non-`nfsuser` export users, like FTP).
  #   - `stat` remains unchanged, returning the real UIDs/GIDs to the client.
  #     - thus programs which check `uid` or `gid` before trying an operation may incorrectly conclude they can't perform some op.
  #
  # 10.0.0.0/8 to export both to LAN (readonly, unencrypted) and wg vpn (read-write, encrypted)
  services.nfs.server.exports =
  let
    fmtExport = { export, baseOpts, extraLanOpts ? [], extraVpnOpts ? [] }:
      let
        always = [ "subtree_check" ];
        lanOpts = always ++ baseOpts ++ extraLanOpts;
        vpnOpts = always ++ baseOpts ++ extraVpnOpts;
      in "${export} 10.78.79.0/22(${lib.concatStringsSep "," lanOpts}) 10.0.10.0/24(${lib.concatStringsSep "," vpnOpts})";
  in lib.concatStringsSep "\n" [
    (fmtExport {
      export = "/";
      baseOpts = [ "crossmnt" "fsid=root" ];
      extraLanOpts = [ "ro" ];
      extraVpnOpts = [ "rw" "no_root_squash" ];
    })
    (fmtExport {
      # provide /media as an explicit export. NFSv4 can transparently mount a subdir of an export, but NFSv3 can only mount paths which are exports.
      export = "/media";
      baseOpts = [ "crossmnt" ];  # TODO: is crossmnt needed here?
      extraLanOpts = [ "ro" ];
      extraVpnOpts = [ "rw" "no_root_squash" ];
    })
    (fmtExport {
      export = "/playground";
      baseOpts = [
        "mountpoint"
        "all_squash"
        "rw"
        "anonuid=${builtins.toString config.users.users.nfsuser.uid}"
        "anongid=${builtins.toString config.users.groups.export.gid}"
      ];
    })
  ];

  users.users.nfsuser = {
    description = "virtual user for anonymous NFS operations";
    group = "export";
    isSystemUser = true;
  };
}
