{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  passthru = {
    pluginName = "Slack";
  };
  version = "9286d2e-master";
  name = "mantisbt-plugin-slack-${version}";
  src = fetchFromGitHub {
    owner = "mantisbt-plugins";
    repo = "Slack";
    rev = "9286d2eeeb8a986ed949e378711fef5f0bf182dc";
    sha256 = "0nn0v4jc967giilkzrppi5svd04m2hnals75xxp0iabcdjnih0mn";
  };
  installPhase = ''
          sed -i -e "s/return '@' . \\\$username;/return \\\$username;/" Slack.php
          cp -a . $out
  '';
}
