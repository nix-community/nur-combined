{ stdenv
, lib
, fetchFromGitHub
, neovim
, enlightenment
, msgpack
, pkg-config
, cmake }: 

stdenv.mkDerivation {
  pname = "eovim";
  version = "0.2.0";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ neovim enlightenment.efl msgpack pkg-config ];

  src = fetchFromGitHub {
    repo   = "eovim";
    owner  = "jeanguyomarch";
    rev    = "28ac041062b34abf4ace4c83e9114a7d6f9fa53e";
    sha256 = "sha256-TNrNvnQNWaigfc6L7tli3FNzaZorF2LU/+mxnNz+qdM=";
  };

  meta = with lib; {
    description = "Eovim is the Enlightened Neovim (EFL Gui client for Neovim).";
    license = licenses.mit;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
