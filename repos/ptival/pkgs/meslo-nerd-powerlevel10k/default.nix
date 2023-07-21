{ fetchurl, lib, stdenv, unzip }:
let
  pname = "meslo-nerd-powerlevel10k";
  version = "2.3.3";
in
fetchurl {
  name = "${pname}-${version}";
  url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf";

  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    install -D $downloadedFile "$out/share/fonts/truetype/MesloLGS NF Regular.ttf"
  '';
  sha256 = "sha256-T1rYKMy6mpviwLkc5fK2t0h3VWhZa8r1gq37xA6bw50=";

  meta = {
    description = "A version of Apple’s Menlo-Regular font patched for Powerlevel10k";
    homepage = https://github.com/romkatv/powerlevel10k-media/;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ptival ];
    platforms = with lib.platforms; all;
  };
}
