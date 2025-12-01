{ lib, mkTmuxPlugin, fetchFromGitHub, thumbs, replaceVars }:

mkTmuxPlugin rec {
  pluginName = "tmux-thumbs";
  version = "0.5.1-infdev";
  rtpFilePath = "tmux-thumbs.tmux";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = pluginName;
    rev = "60824a826a0f64403fd45ded9be8cf3a130476b2";
    sha256 = "sha256-3MKhZq2ks2rBYACf1kkfRxxXNexHjnQ6/+s1wCfqHeo=";
  };

  patches = [
    (replaceVars ./fix.patch {
      tmuxThumbsDir = "${thumbs}/bin";
    })
  ];

  meta = with lib; {
    homepage = "https://github.com/FliegendeWurst/tmux-thumbs";
    description = "tmux-thumbs with color support";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
