{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  lib,
}:
buildPythonPackage {
  pname = "xontrib-dotdot";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "yggdr";
    repo = "xontrib-dotdot";
    rev = "9aa8821b401c0aba140be0d1f02652653f00c4e6";
    sha256 = "sha256-7gcZcy8o86k3NYeomWd0yT9o/ZyaRJHtbuBhzOP50wQ=";
  };

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  meta = with lib; {
    homepage = "https://github.com/yggdr/xontrib-dotdot";
    license = "Copyright (c) 2024, Konstantin Schukraft  Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.  THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. ";
    description = "Better aliases['..'] = 'cd ..' in the [xonsh shell](https://xon.sh).";
    # maintainers = [maintainers.drmikecrowe];
  };
}
