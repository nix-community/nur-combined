{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "sddm-theme-corners";
  version = "6ff0ff455261badcae36cd7d151a34479f157a3c";
  dontBuild = true;

  src = fetchFromGitHub {
    owner = "aczw";
    repo = "sddm-theme-corners";
    rev = "${version}";
    sha256 = "sha256-CPK3kbc8lroPU8MAeNP8JSStzDCKCvAHhj6yQ1fWKkY=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src/corners $out/share/sddm/themes
  '';

  meta = {
    description = "SDDM theme with corners";
    homepage = "https://github.com/aczw/sddm-theme-corners";
    maintainers = ["lcx12901"];
  };
}
