{ stdenv, fetchurl, unzip }:
let
  pname = "meslo-nerd-powerlevel10k";
  version = "1.0";
in
fetchurl {
  name = "${pname}-${version}";
  url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf";

  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    install -D $downloadedFile "$out/share/fonts/truetype/MesloLGS NF Regular.ttf"
  '';
  sha256 = "055xd88sw0xfpy8mgmdvp7057bksbf1mn1nbxk710j0dw9dzahmg";

  meta = {
    description = "A version of Apple’s Menlo-Regular font patched for Powerlevel10k";
    homepage = https://github.com/romkatv/powerlevel10k-media/;
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ ptival ];
    platforms = with stdenv.lib.platforms; all;
  };
}
