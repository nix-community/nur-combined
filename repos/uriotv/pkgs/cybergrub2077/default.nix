{
  lib,
  stdenv,
  fetchFromGitHub,
  logoName ? "samurai",
}:

stdenv.mkDerivation {
  pname = "cyber-grub-2077";
  version = "unstable-2026-01-31";

  src = fetchFromGitHub {
    owner = "adnksharp";
    repo = "CyberGRUB-2077";
    rev = "86ed7c3af18c3b69dd002b341dbb099daaf39eab";
    sha256 = "sha256-quXluKYzylSnUnbLZbzdygM5pgDwB1PgLV4VAU66Lc0=";
  };

  # Faza instalacji odwzorowująca logikę skryptu install.sh
  installPhase = ''
    mkdir -p $out

    # 1. Kopiujemy pliki motywu z podkatalogu do głównego katalogu wyjściowego (spłaszczamy strukturę)
    cp -r CyberGRUB-2077/* $out/

    # 2. Wybieramy logo z folderu img/logos i zapisujemy jako logo.png
    # Dostępne loga w repo to m.in.: samurai, bios, cyberpunk, glitch...
    if [ -f "img/logos/${logoName}.png" ]; then
      cp "img/logos/${logoName}.png" $out/logo.png
    else
      echo "Ostrzeżenie: Logo '${logoName}' nie istnieje, używam domyślnego 'samurai'."
      cp "img/logos/samurai.png" $out/logo.png
    fi
  '';

  meta = with lib; {
    description = "Cyberpunk 2077 inspired GRUB theme";
    homepage = "https://github.com/adnksharp/CyberGRUB-2077";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
