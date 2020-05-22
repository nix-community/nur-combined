{ stdenv
, ruby, buildRubyGem
}:

buildRubyGem {
  inherit ruby;
  pname = "githug";
  gemName = "githug";
  version = "0.5.0";
  source = {
    sha256 = "0hk4pvbvjxipapzjr9rrhcvm2mxlw4a8f6bsfqgq1wnvlbmmrzc6";
  };

  meta = with stdenv.lib; {
    description = "An interactive way to learn git";
    homepage = "https://github.com/Gazler/githug";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
