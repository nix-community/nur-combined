{ ... }: {
  hardware.sane.enable = true;

  users.groups.scanner.members = [
    "ripper"
    "shelvacu"
  ];

  vacu.packages = ''
    kdePackages.skanlite
    kdePackages.skanpage
    xsane
    simple-scan
    scantailor-universal
    scantailor-advanced

    gnumake
    imagemagick
    colord
  '';

  environment.pathsToLink = [
    # "/share/argyllcms"
    "/share/color"
  ];
}
