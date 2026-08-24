{
  fetchurl,
  tonelib,

  gtk3,
  stdenv,
  webkitgtk_4_1,
}:
tonelib.mkToneLib {
  pname = "zoom";
  version = "4.3.1";
  src = fetchurl {
    url = "https://www.tonelib.net/download/ToneLib-Zoom-amd64.deb";
    sha256 = "sha256-4q2vM0/q7o/FracnO2xxnr27opqfVQoN7fsqTD9Tr/c=";
  };

  product = "Zoom";

  buildInputs = [
    gtk3
    stdenv.cc.cc.lib
    webkitgtk_4_1
  ];

  meta = {
    description = "Best way to manage your Zoom processor";
    homepage = "https://tonelib.net/tonelib-zoom.html";
    knownVulnerabilities = [
      "libsoup2 is EOL"
    ];
    insecure = true; # https://github.com/NixOS/nixpkgs/issues/360897
  };
}
