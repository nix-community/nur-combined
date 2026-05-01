{
  pname,
  version,

  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm,
  fetchurl,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "${pname}-${version}.vsix";

  src = fetchFromGitHub {
    owner = "oxc-project";
    repo = "oxc-vscode";
    tag = "v${version}";
    hash = "sha256-3gOptQerusFUrluivW+hORpCYuZcVqo4tIuL2nUByW8=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/oxc-project/oxc-vscode/pull/241.patch";
      hash = "sha256-AjjNAnFcoifPTI2jPYQ3L90L6udnoSUuR1aD2+NS1kI=";
    })
  ];

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpm # At least required by pnpmConfigHook, if not other (custom) phases
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit pname version;
    inherit (finalAttrs) src;
    fetcherVersion = 3;
    hash = "sha256-kJ8rmw31oeIxELA2BATLj3KxxVy54s9VMfxzqjS7Mwg=";
  };

  icon = fetchurl {
    url = "https://cdn.jsdelivr.net/gh/oxc-project/oxc-assets/black-bg-circle.png";
    hash = "sha256-w7Jb0coGggP9iJEgeEEVFd6hNlz5lZPi+SvKeCPTppg=";
  };

  buildPhase = ''
    cp ${finalAttrs.icon} ./icon.png
    pnpm run compile
  '';

  installPhase = ''
    npm exec --package=@vscode/vsce -- vsce package --out $out
  '';
})
