let
  pim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";
  users = [ pim ];

  ojs   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNnavv0c8Htl2OSN9sFM/aFm6FbxvHwTLZDjgb5g1zh";
  lego1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/5cm8VDfCN5y05tcX16tZl3rR+kEgznsrEw1FAaoez";
  rodin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkMd+l2gSXGsWs4FypOt58GTgGruSHravDHPSW1w8XM";
  systems = [ ojs lego1 rodin];
in
{
  "openai-api-key.age".publicKeys = [ pim  ojs lego1 rodin];
  "openai-api-key-plain.age".publicKeys = [ pim  ojs lego1 rodin];

  "aws-credentials-copy.age".publicKeys = [ pim  ojs lego1 rodin];
}
