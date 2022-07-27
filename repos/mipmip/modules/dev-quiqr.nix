{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ansible
    terraform
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
