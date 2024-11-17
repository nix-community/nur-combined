{ lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, git
, gtk3
, libayatana-appindicator
}:
buildGoModule rec {
  pname = "tailscale-systray";
  version = "2023-12-14";

  src = fetchFromGitHub {
    owner = "C10udburst";
    repo = pname;
    rev = "098295b38458d2637b307dd1875b478ec9550601";
    sha256 = "sha256-tjQslHOLuX2QQ9OgPT5Hpllc+mgMBIKUBj/klIlzJys=";
  };

  vendorHash = let
    version = builtins.substring 0 5 lib.version;
  in {
    "23.11" = "sha256-xgvZnRTyCF+JhTxpreO6iMkJ0kPQ9KaDZ0kUr1AOC+8=";
    "24.05" = "sha256-JheeyKs4usRiBGnJN4qY/2hSW5JuWK7CFJclsbCDlfk=";
    "24.11" = "sha256-JheeyKs4usRiBGnJN4qY/2hSW5JuWK7CFJclsbCDlfk=";
    "25.05" = "sha256-JheeyKs4usRiBGnJN4qY/2hSW5JuWK7CFJclsbCDlfk=";
  }.${version}; # DISGOSTAN

  nativeBuildInputs = [ pkg-config git ];
  buildInputs = [ gtk3 libayatana-appindicator ];

  preConfigure = ''
    HOME=$TMPDIR
    go generate .
  '';

  proxyVendor = true;

  meta = with lib; {
    description = "Tailscale systray";
    homepage = "https://github.com/C10udburst/tailscale-systray";
    license = licenses.gpl3;
  };
}
