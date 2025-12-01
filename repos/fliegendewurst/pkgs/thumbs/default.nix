{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "thumbs";
  version = "0.5.1-infdev";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = "tmux-thumbs";
    rev = "60824a826a0f64403fd45ded9be8cf3a130476b2";
    sha256 = "sha256-3MKhZq2ks2rBYACf1kkfRxxXNexHjnQ6/+s1wCfqHeo=";
  };

  patches = [ ./fix.patch ];

  cargoHash = "sha256-vQZJi6KAvToLlyI5ZO/xH1tLhTr7ZrXSNh1NFRjvc1E=";

  meta = with lib; {
    homepage = "https://github.com/FliegendeWurst/tmux-thumbs";
    description = "A lightning fast version copy/pasting like vimium/vimperator";
    license = licenses.mit;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
