{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "rom64";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "mroach";
    repo = "rom64";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1HXDPPxrSVHN/Bggr1yeUxpZYT6vmU4XI09K0KkEsdg=";
  };

  vendorHash = "sha256-0LsZwZtDS3Q9TZQfwpA+ZZ/TIjORbZUmZGuk+yvN6zY=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/mroach/rom64/version.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  doInstallCheck = true;

  meta = {
    description = "N64 ROM utility";
    homepage = "https://github.com/mroach/rom64";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "rom64";
  };
})
