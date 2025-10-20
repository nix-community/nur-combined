{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  libkrb5, # <-- this is pkgs.krb5 (C library)
  enableKerberos ? true,
  pyRev,
  pyHash,
}:

let
  pname = "evil-winrm-py";
  src = fetchFromGitHub {
    owner = "adityatelange";
    repo = "evil-winrm-py";
    rev = pyRev;
    hash = pyHash;
  };
  version = lib.removePrefix "v" pyRev;
in
python3Packages.buildPythonApplication rec {
  inherit pname version src;
  format = "setuptools";

  nativeBuildInputs = [ python3Packages.pythonRelaxDepsHook ];

  # Upstream only pins these three; no need to relax more.
  pythonRelaxDeps = [
    "pypsrp"
    "prompt_toolkit"
    "tqdm"
  ];

  # Runtime deps (Python)
  propagatedBuildInputs =
    (with python3Packages; [
      pypsrp
      prompt_toolkit
      tqdm
      requests
    ])
    ++ lib.optionals enableKerberos (
      with python3Packages;
      [
        gssapi # imports as gssapi
        pyspnego # imports as spnego
        krb5 # Python binding (PyPI "krb5"), imports as krb5
      ]
    )
    # Optional: also include the C lib explicitly (gssapi already brings it)
    ++ lib.optionals enableKerberos [ libkrb5 ];

  # No need for buildInputs; we propagated the C lib above so it’s in the closure.
  doCheck = false;

  # Light sanity: ensures module loads
  pythonImportsCheck = [
    "evil_winrm_py"
  ]
  ++ lib.optionals enableKerberos [
    "gssapi"
    "spnego"
    "krb5"
  ];

  postInstall = ''
    for bin in evil-winrm-py ewp; do
      [ -x "$out/bin/$bin" ] || { echo "ERROR: missing $bin" >&2; exit 1; }
    done
  '';

  meta = with lib; {
    description = "Interactive WinRM shell (Python) with NTLM/hash/cert/Kerberos and in-memory ops";
    homepage = "https://github.com/adityatelange/evil-winrm-py";
    license = licenses.mit;
    mainProgram = "evil-winrm-py";
    platforms = platforms.linux;
  };
}
