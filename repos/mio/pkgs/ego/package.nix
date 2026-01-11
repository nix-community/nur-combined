{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeBinaryWrapper,
  acl,
  xorg,
  libxcb,
}:

rustPlatform.buildRustPackage rec {
  pname = "ego";
  version = "1.2.0-unstable-20260110";

  src = fetchFromGitHub {
    owner = "intgr";
    repo = "ego";
    rev = "dd4ae1040919c551b894a76a7ec5301111ba9dc9"; # version;
    hash = "sha256-1pnRz6ydsE1Ob46z5721S0wkfwaNw1ZMnGH4sNmmKEU=";
  };

  buildInputs = [
    acl
    libxcb
  ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  cargoHash = "sha256-+RwS0eNYPRkab0UYLGluCRdlf2j+T7tgJGVNKOmIyVk=";

  # requires access to /root
  checkFlags = [
    "--skip tests::test_check_user_homedir"
  ];

  preCheck = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ libxcb ]}:$LD_LIBRARY_PATH"
  '';

  postInstall = ''
    wrapProgram $out/bin/ego \
      --prefix PATH : ${lib.makeBinPath [ xorg.xhost ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libxcb ]}
  '';

  meta = {
    description = "Run Linux desktop applications under a different local user";
    homepage = "https://github.com/intgr/ego";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dit7ya ];
    mainProgram = "ego";
  };
}
