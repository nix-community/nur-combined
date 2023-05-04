{ config, lib, sane-lib, ... }:

with lib;
let
  host = config.networking.hostName;
  user-pubkey-full = config.sane.ssh.pubkeys."colin@${host}" or {};
  user-pubkey = user-pubkey-full.asUserKey or null;
  host-keys = filter (k: k.user == "root") (attrValues config.sane.ssh.pubkeys);
  known-hosts-text = concatStringsSep
    "\n"
    (map (k: k.asHostKey) host-keys)
  ;
in
{
  # ssh key is stored in private storage
  sane.user.persist.private = [ ".ssh/id_ed25519" ];
  sane.user.fs.".ssh/id_ed25519.pub" =
    mkIf (user-pubkey != null) (sane-lib.fs.wantedText user-pubkey);
  sane.user.fs.".ssh/known_hosts" = sane-lib.fs.wantedText known-hosts-text;

  users.users.colin.openssh.authorizedKeys.keys =
  let
    user-keys = filter (k: k.user == "colin") (attrValues config.sane.ssh.pubkeys);
  in
    map (k: k.asUserKey) user-keys;
}
