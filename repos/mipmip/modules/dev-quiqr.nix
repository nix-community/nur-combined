{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mipmip_pkg.embgit

    ansible
    terraform
    aws
    awscli2

    act
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
  ]
  else
  [
  ]
  );
}
