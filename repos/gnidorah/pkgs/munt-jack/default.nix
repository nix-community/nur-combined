{ munt, fetchFromGitHub, jack2 }:

munt.overrideAttrs (old: {
  pname = "munt-jack";
  version = "2020-07-26";

  src = fetchFromGitHub {
    owner = "munt";
    repo = "munt";
    # jack_integration branch
    rev = "57d2ebcd32e33dfc4d1a3ec1edc1c652dc0222cb";
    sha256 = "12p281jpg63pnk08xcmapvm9vac9741j8ncjrwg23vlld68grnpx";
  };

  buildInputs = old.buildInputs ++ [ jack2 ];
})
