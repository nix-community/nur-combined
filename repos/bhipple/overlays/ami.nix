# This provides a mechanism for building a custom NixOS AMI
self: super:
let
  mkEC2Image = format: (import (super.path + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      (super.path + "/nixos/maintainers/scripts/ec2/amazon-image.nix")
      {
        ec2.hvm = true;
        amazonImage.format = format;

        # Your custom config here.
        environment.systemPackages = [
          self.git
          self.htop
          self.tmux
          self.zsh
        ];
      }
    ];
  }).config.system.build.amazonImage;

  ec2-image = super.recurseIntoAttrs {
    qcow2 = mkEC2Image "qcow2";
    vhd = mkEC2Image "vpc";
  };
in {
  inherit ec2-image;
}
