{ stdenv, runCommand, fetchgit, python3,
configFile ? ''
  CITY = "Poznań"
  STREET = "ul. Święty Marcin"
  NUMBER = "1"
  HOUSING = "zamieszkana"
  TOKEN = "token"
''
}:
with stdenv.lib;

let
  packages = p: with p; [
    requests
  ];
  py = python3.withPackages packages;
in
stdenv.mkDerivation {
  name = "wywozik-todo";

  src = fetchgit {
    url = "https://github.com/pniedzwiedzinski/wywozik-todo";
    rev = "d214fda2a4c9900086f2d0678a2d6f96ce7a69df";
    sha256 = "1lsmgh07dz0iqw3kd6yq7m2rpss7jx8721jmh2vyvnbybb1cna37";
  };

  buildInputs = [ py ];

  buildPhase = ''
      sed -i '1s:^:#!${py}/bin/python\n:' main.py
      chmod +x main.py
  '';

  installPhase = ''
      mkdir -p $out/bin
      cp main.py $out/main.py
      echo '${configFile}' > $out/config.py

      ln -s $out/main.py $out/bin/wywozik-todo
  '';

  meta = {
    homepage = "https://github.com/pniedzwiedzinski/wywozik-todo";
  };
}
