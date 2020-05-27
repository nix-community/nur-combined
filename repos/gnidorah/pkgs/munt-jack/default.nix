{ munt, fetchFromGitHub, jack2 }:

munt.overrideAttrs (old: {
  pname = "munt-jack";
  version = "2020-03-29";

  src = fetchFromGitHub {
    owner = "munt";
    repo = "munt";
    # jack_integration branch
    rev = "24d133841479326fa3b4ceb222885240e7ee0989";
    sha256 = "0v1bc541kmx8xz4x7m5f693qxgcqnwhgy489zsmcs2c2z5iiz44q";
  };

  buildInputs = old.buildInputs ++ [ jack2 ];
})
