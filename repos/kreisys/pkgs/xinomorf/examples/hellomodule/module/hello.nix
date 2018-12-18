{ pkgs }:

{ resource, provisioner, ... }:

{ greeting }:

let pkgs = import <nixpkgs> {}; in

[
  (
    resource "null_resource" "hello" {
      triggers = {
        uuid = "\${uuid()}";
      };
    } [
      (provisioner "local-exec" {
        # Demonstrate creating an ad-hoc script
        command = pkgs.writeScript "test" ''
          echo "${greeting}"
        '';
      })
    ]
  )
]
