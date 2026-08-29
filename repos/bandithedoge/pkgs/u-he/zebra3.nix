{
  u-he,

  libxcb-cursor,
}:
u-he.mkUhe {
  pname = "u-he-zebra3";
  version = "301_22165";

  product = "Zebra3";
  hash = "sha256-u25uYcuf3q1b5hRipptWa8LdXk8JTlwlq6pgnLKaYLQ=";

  buildInputs = [ libxcb-cursor ];

  postBuild = ''
    mkdir -p $out/libexec/Zebra3/{Modules/{Envelope,LFO,MSEG},Tunefiles}/User
  '';

  meta = {
    homepage = "https://u-he.com/products/synths/zebra3/";
    description = "Deep Synthesis";
  };
}
