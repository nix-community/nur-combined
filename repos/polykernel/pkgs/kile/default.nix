{
  lib,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  scdoc,
}:

rustPlatform.buildRustPackage rec {
  pname = "kile";
  version = "main";

  src = fetchFromGitLab {
    owner = "snakedye";
    repo = pname;
    rev = "main";
    sha256 = "sha256-bWtuLSw4e57YOjdzbY7yobbe4kp67YzG15nhNce3pxA=";
  };

  cargoHash = "sha256-0D9DuEDQo6pCsVMg937kXjVfXMYl/Oxae3a3enN56Kw=";

  nativeBuildInputs = [ scdoc ];

  strictDeps = true;

  postInstall = ''
    install -D doc/kile.1.gz -t "$out/share/man/man1/"
  '';

  meta = with lib; {
    description = "a layout client for river with support for dynamic layouts using a powerful lisp-like syntax.";
    homepage = "https://gitlab.com/snakedye/kile";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
