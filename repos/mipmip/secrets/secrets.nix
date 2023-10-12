let
  pim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";
  users = [ pim ];

  ojs   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNnavv0c8Htl2OSN9sFM/aFm6FbxvHwTLZDjgb5g1zh";
  lego1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/5cm8VDfCN5y05tcX16tZl3rR+kEgznsrEw1FAaoez";
  systems = [ ojs lego1 ];
in
{
  "pim-desktop-password.age".publicKeys = [ pim ojs lego1];
  "pim-server-password.age".publicKeys = [ pim ];
  "openai-api-key.age".publicKeys = [ pim ojs ];
}
