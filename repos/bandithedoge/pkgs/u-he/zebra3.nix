{
  u-he,

  libxcb-cursor,
}:
u-he.mkUhe {
  pname = "u-he-zebra3";
  version = "302_22175";

  product = "Zebra3";
  hash = "sha256-9Mm9EjRAhYh1j+t0GB+hfRa0I0iN80+T3nY7Bue2R7I=";

  buildInputs = [ libxcb-cursor ];

  postBuild = ''
    mkdir -p $out/libexec/Zebra3/{Modules/{Envelope,LFO,MSEG},Tunefiles}/User
  '';

  meta = {
    homepage = "https://u-he.com/products/synths/zebra3/";
    description = "Deep Synthesis";
  };
}
