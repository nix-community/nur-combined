{ fetchFromGitHub
, stdenvNoCC
, runtimeShell, python3Packages
, findutils, bitwarden-cli
}: stdenvNoCC.mkDerivation {
  pname = "pass2bitwarden";
  version = "2019-05-31";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "pass2bitwarden";
    rev = "15f57882f9313c17a2a7589923972e96d115acff";
    sha256 = "02843c9vw4w1h072nznfd5cjxbjl8km35fwy2ar6l3ydbc3mby64";
  };
  passAsFile = [ "importTemplate" ];
  importTemplate = ''
    #!@runtimeShell@
    echo "Purge your vault first, then press enter to import"
    read

    @findutils@/bin/find ''${PASSWORD_STORE_DIR-$HOME/.password-store} -maxdepth 1 -mindepth 1 -type d \
      -not -name .archive -not -name .git -not -name .retired -not -name old -not -name tokens \
      -print0 | @findutils@/bin/xargs -0 @python@/bin/python @out@/share/@pname@/pass2bw.py | @bw@/bin/bw import bitwardencsv /dev/stdin
  '';

  python = python3Packages.python.withPackages (ps: [ ps.python-gnupg ]);
  inherit findutils runtimeShell;
  bw = bitwarden-cli;

  buildPhase = ''
    substituteAll $importTemplatePath pass2bw
  '';

  installPhase = ''
    install -Dm0644 -t $out/share/$pname *.py
    install -Dm0755 -t $out/bin pass2bw
  '';
}
