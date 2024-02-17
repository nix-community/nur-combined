{ pkgs }:
pkgs.lib.makeScope pkgs.newScope (self:
let
  callPackage = self.callPackage;
in
{
  ack-results-parser = callPackage ./ack-results-parser { };
  koji = callPackage ./koji { };
  pybeam = callPackage ./pybeam { };
  python-hwinfo = callPackage ./python-hwinfo { };
  python-ollama = callPackage ./python-ollama { };
  python-qpid-proton = callPackage ./python-qpid-proton { };
  python-requests-gssapi = callPackage ./python-requests-gssapi { };
  rpmlint = callPackage ./rpmlint { };
})
