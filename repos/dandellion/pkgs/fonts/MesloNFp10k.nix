{ runCommand, fetchurl }:

let
  commit = "54fbc18ea84d15807f921146c1689539b62a6061";
  regular = fetchurl {
    name = "MesloLGSNFRegular.ttf";
    url = "https://github.com/romkatv/powerlevel10k-media/raw/${commit}/MesloLGS%20NF%20Regular.ttf";
    sha256 = "1jydmjlhssvmj0ddy7vzn0cp6wkdjk32lvxq64wrgap8q9xy14li";
  };
  bold = fetchurl {
    name = "MesloLGSNFBold.ttf";
    url = "https://github.com/romkatv/powerlevel10k-media/raw/${commit}/MesloLGS%20NF%20Bold.ttf";
    sha256 = "0w9byh20804qscsj13wj9v3llaqqzbkg5dmpwf0yqmxcvgs8dp7b";
  };
  italic = fetchurl {
    name = "MesloLGSNFItalic.ttf";
    url = "https://github.com/romkatv/powerlevel10k-media/raw/${commit}/MesloLGS%20NF%20Italic.ttf";
    sha256 = "1442jp3zh92fz7fs5xn4853djnbchkqj7i09avnhpgp9bbn07fzz";
  };
  boldItalic = fetchurl {
    name = "MesloLGSNFBoldItalic.ttf";
    url = "https://github.com/romkatv/powerlevel10k-media/raw/${commit}/MesloLGS%20NF%20Bold%20Italic.ttf";
    sha256 = "0g5q6my8k6aaf26sq610v9v17j3gsba63f1wv2yix48sdj3pxvbz";
  };
in
runCommand "meslo-NF-p10k" {}
  ''
    mkdir -p $out/share/fonts/truetype
    ln -s "${regular}" "${bold}" "${italic}" "${boldItalic}" $out/share/fonts/truetype
  ''
