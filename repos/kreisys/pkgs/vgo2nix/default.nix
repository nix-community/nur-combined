{ buildGoPackage, fetchFromGitHub, go, lib, makeWrapper, nix-prefetch-git, stdenv }:

assert lib.versionAtLeast go.version "1.11";

let
  isCommitHash   = rev: (builtins.match "[a-f0-9]{40}" rev) != null;
  trimCommitHash = builtins.substring 0 7;
  pin            = lib.importJSON ./pin.json;

in buildGoPackage rec {
  name              = "vgo2nix-${version}";
  version           = if isCommitHash pin.rev then trimCommitHash pin.rev else pin.rev;
  goPackagePath     = "github.com/adisbladis/vgo2nix";
  nativeBuildInputs = [ makeWrapper ];
  src               = fetchFromGitHub pin;
  goDeps            = ./deps.nix;
  allowGoReference  = true;

  postInstall = with stdenv; let
    binPath = lib.makeBinPath [ nix-prefetch-git go ];
  in ''
    wrapProgram $bin/bin/vgo2nix --prefix PATH : ${binPath}
  '';

  meta = with stdenv.lib; {
    description = "Convert go.mod files to nixpkgs buildGoPackage compatible deps.nix files";
    homepage    = https://github.com/adisbladis/vgo2nix;
    license     = licenses.mit;
    maintainers = with maintainers; [ adisbladis ];
  };

}
