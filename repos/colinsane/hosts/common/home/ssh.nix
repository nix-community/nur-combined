# TODO: this should be moved to users/colin.nix
{ config, lib, ... }:

let
  host = config.networking.hostName;
  user-pubkey-full = config.sane.ssh.pubkeys."colin@${host}" or {};
  user-pubkey = user-pubkey-full.asUserKey or null;
  host-keys = lib.filter (k: k.user == "root") (lib.attrValues config.sane.ssh.pubkeys);
  known-hosts-text = lib.concatStringsSep
    "\n"
    (builtins.map (k: k.asHostKey) host-keys)
  ;
in
{
  # ssh key is stored in private storage
  sane.user.persist.byStore.private = [
    { type = "file"; path = ".ssh/id_ed25519"; }
  ];
  sane.user.fs.".ssh/id_ed25519.pub" = lib.mkIf (user-pubkey != null) {
    symlink.text = user-pubkey;
  };
  sane.user.fs.".ssh/known_hosts".symlink.text = known-hosts-text;

  users.users.colin.openssh.authorizedKeys.keys =
  let
    user-keys = lib.filter (k: k.user == "colin") (lib.attrValues config.sane.ssh.pubkeys);
  in
    builtins.map (k: k.asUserKey) user-keys;
}
