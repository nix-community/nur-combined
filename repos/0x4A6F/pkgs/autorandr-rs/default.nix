{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, scdoc
}:

rustPlatform.buildRustPackage rec {
  pname = "autorandr-rs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = "autorandr-rs";
    rev = version;
    sha256 = "0ysfaamdj6mv943nkhla95zl5mzi5rlyzw63rwswxbs0icxkycjx";
  };

  cargoSha256 = "1ifyy54g4z2l4v78r8cayww0cslwf3i3capykl93661ybyld4q6w";

  nativeBuildInputs = [
    scdoc
  ];

  meta = with lib; {
    description = "like autorandr, but toml and a daemon";
    homepage = "https://github.com/theotherjimmy/autorandr-rs";
    license = licenses.unfree;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.all;
  };
}
