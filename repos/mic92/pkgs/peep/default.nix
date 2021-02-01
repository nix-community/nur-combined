{ lib, fetchFromGitHub, rustPlatform, fetchpatch }:
rustPlatform.buildRustPackage rec {
  pname = "peep-unstable";
  version = "2020-02-06";

  src = fetchFromGitHub {
    owner = "ryochack";
    repo = "peep";
    rev = "af77c63c264bc009254a46eede8f7136c6d64ea4";
    sha256 = "1yiad9zv6f8bjiq7774hchm0q7bcng3mlgmdqnla1vny36vn4jdq";
  };

  cargoPatches = [
    (
      fetchpatch {
        url = "https://github.com/ryochack/peep/commit/f595ed9a6722a1dd8fa5aedd1331a3e97e8b4de2.patch";
        sha256 = "0cz0gwn0mip8hpyh1v9mpav8vcwmviq4hiraa4gg84v01v8c9b51";
      }
    )
  ];

  cargoSha256 = "1lj3x84l37lqggkqnsxlnnmpjk29krzn5bgqcq4749nsdp72hrvs";

  meta = with lib; {
    description = "The CLI text viewer tool that works like less command on small pane within the terminal window.";
    inherit (src.meta) homepage;
    license = licenses.mit;
  };
}
