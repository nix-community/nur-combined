{ home-manager
, modules
, pkgs
, nixpkgs
}:

import "${nixpkgs}/nixos/tests/make-test-python.nix" ({ pkgs, ...}: {
  name = "unoconvservice";
  nodes = let
  in {
    client = { ... }: {};
    server1 =
      { ... }:
      {
        imports = [ modules.unoconvservice ]; 
        services.unoconvservice = {
          enable = true;
          timeout = 30000;
          timeoutStartSec = "10min";
          port = 8080;
        };
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 8080 ];
        };
      };
  };

  testScript = let
    runAsBob = cmd: "sudo -u bob ${cmd}";
    example_docx = ./data/example.docx;
  in ''
    start_all()
  
    server1.wait_for_unit("container@unoconvserver")

    client.succeed("cp ${example_docx} example.docx")
    server1.succeed(
      'nixos-container run unoconvserver -- cp ${example_docx} example.docx 1>&2'
    )
    server1.wait_until_fails(
      "nixos-container run unoconvserver -- ${pkgs.curl}/bin/curl http://0.0.0.0:3000/healthz 2>&1 | grep 'Connection refused'"
    )
    server1.succeed(
      "nixos-container run unoconvserver -- ${pkgs.curl}/bin/curl --form file=@example.docx http://0.0.0.0:3000/unoconv/pdf -o example.pdf 1>&2"
    )
    server1.succeed(
      "nixos-container run unoconvserver -- ${pkgs.file}/bin/file example.pdf 1>&2"
    )
    client.succeed(
      "${pkgs.curl}/bin/curl --form file=@example.docx http://server1:8080/unoconv/pdf > example.pdf"
    )
    client.copy_from_vm("example.pdf")
    server1.succeed(
      "nixos-container run unoconvserver -- systemctl status tfk-api-unoconv -l 1>&2"
    )
    server1.succeed(
      "nixos-container run unoconvserver -- systemctl status nginx -l 1>&2"
    )
    client.succeed(
      '${pkgs.busybox}/bin/strings example.pdf | grep "comment-concilier-surveillance-et-respect-des-libertes"'
    )
  '';
})
