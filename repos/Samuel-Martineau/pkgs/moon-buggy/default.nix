# Copyright (c) 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ lib
, stdenv
, fetchurl
, ncurses
}:
stdenv.mkDerivation rec {
  pname = "moon-buggy";
  version = "1.0.51";

  buildInputs = [
    ncurses
  ];

  src = fetchurl {
    url = "http://m.seehuhn.de/programs/moon-buggy-${version}.tar.gz";
    sha256 = "0gyjwlpx0sd728dwwi7pwks4zfdy9rm1w1xbhwg6zip4r9nc2b9m";
  };

  meta = {
    description = "A simple character graphics game where you drive some kind of car across the moon's surface";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.rybern ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    homepage = "https://www.seehuhn.de/pages/moon-buggy";
  };
}
