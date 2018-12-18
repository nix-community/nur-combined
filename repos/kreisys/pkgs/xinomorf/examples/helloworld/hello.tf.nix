{ resource, provisioner, ... }:

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
          echo "Hello World!"
        '';
      })
    ]
  )
]
