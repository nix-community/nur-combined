{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "kubectx";
  src = fetchFromGitHub {
    owner = "ahmetb";
    repo = "kubectx";
    rev = "3aeb4e76d218590df0554dbbe2b3b7907ccd1f4a";
    sha256 =  "002p277pw93rrfp7r28xpdgj9i3yaqn3hdks96w2zkx48r7n3pg6";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/{kubens,kubectx} $out/bin
    cp -r $src/completion $out/
  '';

  meta.description = ''Convenience bash scripts for working with multiple repos'';
}
