{ fetchFromGitHub
, stdenv
, lib
, cmake
, gcc9
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "luau-lsp";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "JohnnyMorganz";
    repo = "luau-lsp";
    rev = finalAttrs.version;
    hash = "sha256-qdQNrdjzyx3fBVFBAwzb4hBZhTfmUhSKtfHhB4yY6Wk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ]
    ++ lib.optional stdenv.isLinux gcc9;
 
  buildPhase = ''
    runHook preBuild
    cmake ..
    cmake --build . --target Luau.LanguageServer.CLI --config Release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./luau-lsp $out/bin/luau-lsp
    runHook postInstall
  '';

  meta = {
    description = "Language Server for Luau";
    homepage = "https://github.com/JohnnyMorganz/luau-lsp";
    downloadPage = "https://github.com/JohnnyMorganz/luau-lsp/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux; 
    # maintainers = with lib.maintainers; [ eggflaw ];
    mainProgram = "luau-lsp";
  };
})
