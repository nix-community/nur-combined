{ keepassxc, coreutils, stdenv, lib }: stdenv.mkDerivation {
  pname = "run-keepass";
  version = "2023-02-11";

  src = ./run-keepass;

  buildInputs = [
    keepassxc
    coreutils
  ];

  meta = with lib; {
    description = "an app to run keepass using secrets specified at compile time";
    longDescription = ''
      When running keepassxc the user who's running the application must normally have access to read a file
      containing the keepass database password, but if you use SETUID with this application you can permit it
      to run keepass without letting the user read the password file except to open keepassxc

      This probably doesn't make much sense without https://github.com/Minion3665/NixFiles
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ minion3665 ];
  };
}
