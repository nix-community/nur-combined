{ stdenv, lib, fetchgit }: 

stdenv.mkDerivation rec {
  pname = "solarized-icons";
  version = "1.0";

  src = fetchgit {
    url = "https://github.com/rtlewis88/rtl88-Themes";
    rev = version;
    sha256 = "sha256-AWpJ7o4tW3uMz8w84Jp2d/Tr5GnO3EypeHectMhaols=";
  };

  installPhase = ''
    mkdir -p $out/share/icons
    tar -xvf Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz -C $out/share/icons
  '';

  meta = with lib; {
    description = "Solarized-cursors";
    homepage = "https://github.com/rtlewis88/rtl88-Themes";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
