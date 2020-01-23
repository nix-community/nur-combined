{ pkgs }:

with pkgs.lib; {
  # Note: Your password will be stored in cleartext in your /nix/store!
  #       Use this function only if you want to protect a password for
  #       a config that you want to put in a public git reporsitory.
  # generate cipher with
  # echo -n YourSecretPassword | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -a -e -kfile ../pw
  aes-cbc =
    pkgs : passwordFile : secretsFile : name:
    pkgs.lib.removeSuffix "\n" (builtins.readFile (pkgs.runCommand name {} ''
      awk '$1 == "${name}" {print $2}' ${secretsFile} | \
      ${pkgs.openssl}/bin/openssl enc -aes-256-cbc -md sha512 -pbkdf2 -a -d \
      -kfile "${passwordFile}" -out $out
    ''));
}

