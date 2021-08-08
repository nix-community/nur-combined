{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "gemini-ipfs-gateway";
  version = "2021-03-23";

  src = fetchFromSourcehut {
    owner = "~hsanjuan";
    repo = pname;
    rev = "918ef8ab2691cb7af7048c9ca3d2015b6ad45f91";
    hash = "sha256-ERRqeSDnAkhjlcOYS6CBP+/YZBGXoCtjGOlcmdYjLhI=";
  };

  vendorSha256 = "sha256-LKJb3YpnydkPHSCR3ioTRDWW5R+HucY8tPfqOuS06h0=";

  meta = with lib; {
    description = "IPFS access over the Gemini protocol";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
