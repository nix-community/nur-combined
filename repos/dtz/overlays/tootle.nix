self: super: {
  tootle = super.tootle.overrideAttrs (o: rec {
    name = "tootle-${version}";
    version = "2018-10-23";
    src = super.fetchFromGitHub {
      owner = "bleakgrey";
      repo = "tootle";
      rev = "534ff38feda3b6467e62edf0045d5ca097790a3b";
      sha256 = "0xi1gspqqkqpl8a2smvaxcj7kq0q8bhfl424cw04a3rvjn9a1z59";
    };
  });
}
