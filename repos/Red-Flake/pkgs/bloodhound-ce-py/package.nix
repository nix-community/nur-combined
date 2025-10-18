{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python ? null, # we’ll pass pkgs.python312 from default.nix
  pyRev ? "bloodhound-ce", # branch or commit
  pyHash, # <<< fill after first build attempt
}:

let
  py = python;
  pkgsP = py.pkgs;
in
pkgsP.buildPythonApplication rec {
  pname = "bloodhound-ce-py";
  version = pyRev;

  src = fetchFromGitHub {
    owner = "dirkjanm";
    repo = "BloodHound.py";
    rev = pyRev;
    sha256 = pyHash;
  };

  format = "setuptools";

  propagatedBuildInputs = with pkgsP; [
    impacket
    ldap3
    dnspython
    requests
    tqdm
    future
  ];

  doCheck = false;
  pythonImportsCheck = [ "bloodhound" ];

  nativeBuildInputs = [ makeWrapper ];

  # Create a guaranteed launcher, independent of setuptools’ console_scripts
  postInstall = ''
    mkdir -p "$out/bin"
    cat > "$out/bin/bloodhound.py" <<'SH'
    #!${py.interpreter}
    import runpy, sys
    if __name__ == "__main__":
        sys.exit(runpy.run_module("bloodhound", run_name="__main__", alter_sys=True))
    SH
    chmod +x "$out/bin/bloodhound.py"

    # "Installed launcher: $out/bin/bloodhound.py"
    # Let's also add some aliases
    ln -s "$out/bin/bloodhound.py" "$out/bin/bloodhound-ce.py"
    ln -s "$out/bin/bloodhound.py" "$out/bin/bloodhound-ce-py"
    ln -s "$out/bin/bloodhound.py" "$out/bin/bhce.py"
  '';

  meta = with lib; {
    description = "BloodHound.py (Community Edition branch) – Python collector for BloodHound CE";
    homepage = "https://github.com/dirkjanm/BloodHound.py";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "bloodhound-ce-py";
  };
}
