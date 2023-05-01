{ lib }:
let
  inherit (lib) fileContents;
  importUser = (user: {
    # bcrypt hashed: `htpasswd -BnC 10 ""`
    passwordHash = fileContents (./. + "/${user}/password-hash.txt");
    # base32 encoded: `printf '<secret>' | base32  | tr -d =`
    totpSecret = fileContents (./. + "/${user}/totp-secret.txt");
  });
in
{
  auth_key = fileContents ./auth-key.txt;

  users = lib.flip lib.genAttrs importUser [
    "ambroisie"
  ];

  groups = {
    root = [ "ambroisie" ];
  };
}
