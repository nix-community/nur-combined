{ lib }:
{
  secretKey = lib.fileContents ./secret-key-file.secret;
  adminPassword = lib.fileContents ./admin-password.secret;
}
