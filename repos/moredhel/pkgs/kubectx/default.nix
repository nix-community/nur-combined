{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "kubectx";
  src = fetchFromGitHub {
    # url = "https://github.com/ahmetb/kubectx";
    # owner = "ahmetb";
    # repo = "kubectx";
    # rev = "3aeb4e76d218590df0554dbbe2b3b7907ccd1f4a";
    # sha256 =  "0qa2jhfj3spnifbcq6idnxifw6wm9ki6z1vw5f06qw05sfgy00a4";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp {kubens,kubectx} $out/bin
    cp -r completion $out/
  '';

  meta.description = ''Convenience bash scripts for working with multiple repos'';
  meta.broken = true;
}
