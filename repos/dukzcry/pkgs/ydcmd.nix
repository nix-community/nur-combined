{ stdenv, lib, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
  pname = "ydcmd";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "abbat";
    repo = "ydcmd";
    rev = "v${version}";
    sha256 = "sha256-wO5xMzdyzoFONYS9WyIAeN3S2UYfB997QMg+iWkT5P4=";
  };

  propagatedBuildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [ dateutil ]))
  ];

  installPhase = ''
    install -Dm755 ydcmd.py $out/bin/ydcmd
    install -Dm644 man/ydcmd.1 $out/share/man/man1/ydcmd.1
    install -Dm644 man/ydcmd.ru.1 $out/share/man/ru/man1/ydcmd.1
  '';

  meta = with lib; {
    description = "Консольный клиент Linux/FreeBSD для работы с Яндекс.Диск (Yandex.Disk) посредством REST API";
    license = licenses.free;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
