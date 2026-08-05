{
  fetchFromGitHub,
  python3,
  lib,
  sphinx,
  texinfo,
  installShellFiles,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "keylime";
  version = "7.14.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "keylime";
    repo = "keylime";
    tag = "v${version}";
    hash = "sha256-Mdsg4InWz9ekNh/dmXuXBJ2vewr8IoGqfZzMgtnS/Og=";
  };

  outputs = [
    "out"
    "man"
    "info"
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    alembic
    cryptography
    gpgme
    jinja2
    jsonschema
    lark
    packaging
    psutil
    pyasn1
    pyasn1-modules
    pyyaml
    pyzmq
    requests
    sqlalchemy
    tornado
  ];

  nativeBuildInputs =
    with python3.pkgs;
    [
      sphinxcontrib-httpdomain
      sphinxcontrib-bibtex
      sphinx-tabs
      sphinx-rtd-theme
      sphinx-prompt
      recommonmark
      sphinx-notfound-page
    ]
    ++ [
      sphinx
      texinfo
      installShellFiles
    ];

  patchPhase = ''
    runHook prePatch

    substituteInPlace keylime/config.py keylime/cmd/convert_config.py \
      --replace-fail /usr/share/keylime/templates $out/share/keylime/templates

    runHook postPatch
  '';

  postBuild = ''
    make -C docs man info
  '';

  postInstall = ''
    mkdir -pv $out/share/keylime
    cp -r templates $out/share/keylime/templates
    cp -r tpm_cert_store $out/share/keylime/tpm_cert_store

    installManPage docs/_build/man/*.{1,8}

    mkdir -pv ''${!outputInfo}/share/info
    cp docs/_build/texinfo/*.info ''${!outputInfo}/share/info
  '';

  meta = {
    description = "Keylime is an open-source scalable trust system harnessing TPM Technology";
    longDescription = ''
      Keylime is an open-source scalable trust system harnessing TPM Technology.

      Keylime provides an end-to-end solution for bootstrapping hardware rooted
      cryptographic trust for remote machines, the provisioning of encrypted
      payloads, and run-time system integrity monitoring.
      It also provides a flexible framework for the remote attestation of any
      given PCR (Platform Configuration Register).
      Users can create their own customized actions that will trigger when a
      machine fails its attested measurements.

      Keylime's mission is to make TPM Technology easily accessible to
      developers and users alike, without the need for a deep understanding of
      the lower levels of a TPM's operations.
      Amongst many scenarios, it well suited to tenants who need to remotely
      attest machines not under their own full control (such as a consumer of
      hybrid cloud or a remote Edge / IoT device in an insecure physical tamper
      prone location.)
    '';
    homepage = "https://keylime.dev";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
}
