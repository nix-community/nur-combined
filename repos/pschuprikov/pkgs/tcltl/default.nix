{ stdenv, fetchFromGitHub, autoreconfHook, boost, swig, spot, tchecker }:
stdenv.mkDerivation {
  name = "tcltl-HEAD";
  src = fetchFromGitHub {
    owner = "ticktac-project";
    repo = "tcltl";
    rev = "74e6367923989eeb4cdabb016dc022f288dd74ec";
    sha256 = "sha256-8aio4iaO0WLs+EoTgO8q/MRdo2gmkBszbj2i8qP3EAs=";
  };

  patchPhase = ''
    substituteInPlace src/tcltl.cc \
      --replace 'mutable spot::fixed_size_pool statepool_;' \
      'mutable spot::fixed_size_pool<spot::pool_type::Safe> statepool_;'
  '';

  configureFlags = [ "--disable-python" ];

  buildInputs = [ autoreconfHook boost swig spot tchecker ];

}
