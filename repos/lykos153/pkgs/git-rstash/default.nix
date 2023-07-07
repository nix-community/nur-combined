{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "git-rstash";
  version = "4387d032d5e908e4ab2297fdefd5db8225c6192d";
  src = fetchFromGitHub
  {
    owner = "501st-alpha1";
    repo = name;
    rev = "${version}";
    hash = "sha256-ayB7yV7cq5qxn/5ZqaeLNVtW/f6NOtURONmCzZYCRnY=";
  } + "/git-rstash";

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/git-rstash
  '';

  meta = with lib; {
    description = "Transfer your Git stashes to and from remotes with ease!";
    homepage = https://github.com/aklomp/git-rstash;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
