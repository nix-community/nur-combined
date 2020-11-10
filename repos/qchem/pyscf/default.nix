{ lib, buildPythonPackage, fetchFromGitHub
, numpy, scipy, h5py, libcint, libxc
} :

buildPythonPackage rec {
  pname = "pyscf";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "pyscf";
    repo = "pyscf";
    rev = "v${version}";
    sha256 = "1gmx75kqyjb8n3jgnlnzamw7f6cibc6wqsfy4vad6crz58lffjjj";
  };

  propagatedBuildInputs = [ numpy scipy h5py ];
  buildInputs = [ libcint libxc ];

  PYSCF_INC_DIR="${libcint}:${libxc}";

  doCheck = true;

  # setup does not build/install DMRG modules
#  postPatch = ''
#    cat <<EOF > pyscf/dmrgscf/settings.py
#    import os
#    from pyscf import lib
#    PYCHEMPS2BIN = '${chemps2}/lib/libchemps2.so'
#    EOF

#    chmod +x pyscf/dmrgscf/settings.py
#  '';

  meta = with lib; {
    description = "Python-based simulations of chemistry framework";
    homepage = https://pyscf.github.io/;
    license = licenses.asl20;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
