{ stdenvNoCC, makeWrapper, nix, nix-prefetch-git, fennel, luajit }:

stdenvNoCC.mkDerivation {
  pname = "update-vim-plugins";
  version = "0.1";

  src = ../.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    nix
    nix-prefetch-git
    (fennel.override { lua = luajit; })
  ] ++ (with luajit.pkgs; [
    http
    cjson
    lpeg
  ]);

  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out/bin/.unwrapped
    install bin/update-vim-plugins -m 755 $out/bin/.unwrapped/update-vim-plugins
    makeWrapper $out/bin/.unwrapped/update-vim-plugins $out/bin/update-vim-plugins \
      --set PATH "$PATH" \
      --set LUA_CPATH "?.lua;$LUA_CPATH" \
      --set LUA_PATH "?.lua;$LUA_PATH"
  '';
}
