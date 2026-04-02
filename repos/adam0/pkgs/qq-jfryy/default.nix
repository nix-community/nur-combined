{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "qq-jfryy";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-GLZKDKJEtZIsOMj9V7q2Po7DDelhl1tg1DOyihOw2bk=";
  };

  vendorHash = "sha256-x4tEGE/ewE4SjUm9m+NTbKZVLNJsvbNg03Wdw7s4qhI=";

  meta = {
    description = "jq, but with many interoperable configuration format transcodings and interactive querying";
    homepage = "https://github.com/JFryy/qq";
    license = lib.licenses.mit;
    mainProgram = "qq";
    platforms = lib.platforms.unix;
  };
}
