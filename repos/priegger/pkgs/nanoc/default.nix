{ lib
, bundlerApp
}:

bundlerApp {
  pname = "nanoc";
  gemdir = ./.;
  exes = [ "nanoc" ];

  meta = with lib; {
    description = "Nanoc is a flexible static-site generator";
    longDescription = ''
      Nanoc is a static-site generator, fit for building anything from a small
      personal blog to a large corporate website. 
    '';
    homepage = https://nanoc.ws/;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
