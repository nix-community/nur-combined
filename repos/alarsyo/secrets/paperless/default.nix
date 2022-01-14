{ lib }:
let
  inherit (lib)
    fileContents
  ;
in
{
  secretKey = fileContents ./secret-key-file.secret;
  adminPassword = fileContents ./admin-password.secret;
}
