# docs:
# - <https://nixos.wiki/wiki/NFS>
# - <https://wiki.gentoo.org/wiki/Nfs-utils>

{ ... }:
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
    protocol = [ "tcp" ];
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
  # - mountpoint[=/path]:  only export the directory if it's a mountpoint. used to avoid exporting failed mounts.
  #
  # 10.0.0.0/8 to export both to LAN (readonly, unencrypted) and wg vpn (read-write, encrypted)
  services.nfs.server.exports = ''
    /var/export 10.78.79.0/22(ro,crossmnt,fsid=0,subtree_check) 10.0.10.0/24(rw,no_root_squash,crossmnt,fsid=0,subtree_check)
  '';
  # TODO: export playground as read-write to LAN, with forced UID/GID mapping to nfsguest/export
}
