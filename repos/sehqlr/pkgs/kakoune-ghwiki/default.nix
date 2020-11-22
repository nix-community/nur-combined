{ stdenv, fetchFromGitLab }:

stdenv.mkDerivation rec {
  name = "kakoune-ghwiki-${version}";
  version = "2020-02-25";
  src = fetchFromGitLab {
      owner = "Screwtapello";
      repo = "kakoune-ghwiki";
      rev = "138ab6a3bfd8188c6e164691bd1b257b0ce6aac8";
      sha256 = "0cyydkmgn4syfcbs0nqiza05n6cx744n2wvps6apfpnx3ppz04b4";
      };
  installPhase = ''
    mkdir -p $out/share/kak/autoload/plugins/kakoune-ghwiki
    cp -r $src/* $out/share/kak/autoload/plugins/kakoune-ghwiki
    '';

  meta = with stdenv.lib;
  { description = "Teach Kakoune tricks for editing a GitHub-style wiki";
      homepage = "https://github.com/Screwtapello/kakoune-ghwiki";
      license = licenses.mit;
  };
}

