{ lib
, python3
, dbus
, python3Packages
, fetchFromGitHub 
}:
let
  fixedDbusNext = python3Packages.dbus-next.overridePythonAttrs (old: {
    checkPhase = builtins.replaceStrings ["not test_peer_interface"] ["not test_peer_interface and not test_tcp_connection_with_forwarding"] old.checkPhase;
  });
in
python3Packages.buildPythonPackage rec {
  pname = "day-night-plasma-wallpapers";
  version = "2022-02-11";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Day-night-plasma-wallpapers";
    rev = "aae28f1267c5f6820719e87932b670233ed3bbfa";
    sha256 = "sha256-tGEoiN+soP3S7ctNqNjChlqGtW8qMGD3ynX/5rIENfA=";
  };

  propagatedBuildInputs = [ fixedDbusNext ];

  postInstall = ''
    mkdir -p "$out/.config/autostart-scripts"
    ln -s "$out/bin/update-day-night-plasma-wallpapers" "$out/.config/autostart-scripts/update-day-night-plasma-wallpapers"
  '';

  meta = with lib; {
    description = "KDE Plasma utility to automatically change to a night wallpaper when the sun is reaching sunset";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Day-night-plasma-wallpapers";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
