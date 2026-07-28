{ ... }: {
  users.groups.t-pictures.members = [
    "shelvacu"
    "copyparty-two_e14"
  ];

  vacu.packages = ''
    argyllcms
    colord
  '';

  environment.pathsToLink = [
    "/share/argyllcms"
    "/share/color"
  ];

  vacu.copyparties.two_e14.volumes."/t-pictures" = {
    hostPath = "/propdata/t-pictures-useable/final";
    access = "r: julie,shelvacu";
    bind.readOnly = true;
  };
}
