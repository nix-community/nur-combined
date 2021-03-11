{ lib, fetchzip }:

let
  pname = "nerdfont-hasklig";
  version = "2.1.0";
in fetchzip {
  name = "${pname}-${version}";
  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/Hasklig.zip";
  sha256 = "sha256-Y6m8xUgkNXS6Mpup3QfRZJ2gyuT4L8t289iYoTv2n+U=";

  postFetch = ''
    unzip $downloadedFile
    install -Dm 444 *.otf -t $out/share/fonts/otf
  '';

  meta = with lib; {
    description = "A code font based on source code pro with monospaced ligatures extended by nerd fonts";
    longDescription = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = "https://nerdfonts.com/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ jk ];
  };
}
