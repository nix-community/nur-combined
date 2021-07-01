{ fetchPypi, fetchFromGitHub, buildPythonPackage, lib, writeTextFile, writeScript, makeWrapper,
 # Python dependencies
 autograd, dask, distributed, h5py, jinja2, matplotlib, numpy, natsort, pytest, pyyaml, rmsd, scipy,
 sympy, scikitlearn, qcengine, ase, xtb-python, openbabel-bindings,
 # Runtime dependencies
 runtimeShell, jmol ? null, multiwfn ? null, xtb ? null, openmolcas ? null,
 pyscf ? null, psi4 ? null, wfoverlap ? null, nwchem ? null, orca ? null,
 turbomole ? null, gaussian ? null, gamess-us ? null, cfour ? null, molpro ? null,
 # Test dependencies
 openssh,
 # Configuration
 fullTest ? false
}:
let
  psi4Wrapper = writeScript "psi4.sh" ''
    #!${runtimeShell}
    ${psi4}/bin/psi4 -o stdout $1
  '';
  pysisrc =
    let
      gaussian16Conf = {
        cmd = "${gaussian}/bin/g16";
        formchk_cmd = "${gaussian}/bin/formchk";
        unfchk_cmd = "${gaussian}/bin/unfchk";
      };
      text = with lib.lists; lib.generators.toINI {} (builtins.listToAttrs ([ ]
        ++ optional (openmolcas != null) { name = "openmolcas"; value.cmd = "${openmolcas}/bin/pymolcas"; }
        ++ optional (psi4 != null) { name = "psi4"; value.cmd = "${psi4Wrapper}"; }
        ++ optional (wfoverlap != null) { name = "wfoverlap"; value.cmd = "${wfoverlap}/bin/wfoverlap.x"; }
        ++ optional (multiwfn != null) { name = "multiwfn"; value.cmd = "${multiwfn}/bin/Multiwfn"; }
        ++ optional (jmol != null) { name = "jmol"; value.cmd = "${jmol}/bin/jmol"; }
        ++ optional (xtb != null) { name = "xtb"; value.cmd = "${xtb}/bin/xtb"; }
        ++ optional (gaussian != null) { name = "gaussian16"; value = gaussian16Conf; }
        ++ optional (orca != null) { name = "orca"; value.cmd = "${orca}/bin/orca"; }
      ));
    in
      writeTextFile {
        inherit text;
        name = "pysisrc";
      };

  binSearchPath = with lib; makeSearchPath "bin" ([ ]
    ++ lists.optional (jmol != null) jmol
    ++ lists.optional (multiwfn != null) multiwfn
    ++ lists.optional (xtb != null) xtb
    ++ lists.optional (openmolcas != null) openmolcas
    ++ lists.optional (pyscf != null) pyscf
    ++ lists.optional (psi4 != null) psi4
    ++ lists.optional (wfoverlap != null) wfoverlap
    ++ lists.optional (nwchem != null) nwchem
    ++ lists.optional (orca != null) orca
    ++ lists.optional (turbomole != null) turbomole
    ++ lists.optional (gaussian != null) gaussian
    ++ lists.optional (cfour != null) cfour
    ++ lists.optional (molpro != null) molpro
  );

in
  buildPythonPackage rec {
    pname = "pysisyphus";
    version = "0.7.post1";

    nativeBuildInputs = [ makeWrapper ];

    propagatedBuildInputs = with lib; [
      autograd
      dask
      distributed
      h5py
      jinja2
      matplotlib
      numpy
      natsort
      pyyaml
      rmsd
      scipy
      sympy
      scikitlearn
      qcengine
      ase
      openbabel-bindings
      pytest  # Also required for normal execution
      openssh
    ] # Syscalls
      ++ lists.optional (xtb-python != null) xtb-python
      ++ lists.optional (jmol != null) jmol
      ++ lists.optional (multiwfn != null) multiwfn
      ++ lists.optional (xtb != null) xtb
      ++ lists.optional (openmolcas != null) openmolcas
      ++ lists.optional (pyscf != null) pyscf
      ++ lists.optional (psi4 != null) psi4
      ++ lists.optional (wfoverlap != null) wfoverlap
      ++ lists.optional (nwchem != null) nwchem
      ++ lists.optional (orca != null) orca
      ++ lists.optional (turbomole != null) turbomole
      ++ lists.optional (gaussian != null) gaussian
      ++ lists.optional (cfour != null) cfour
      ++ lists.optional (molpro != null) molpro
    ;

    src = fetchFromGitHub {
      owner = "eljost";
      repo = pname;
      rev = version;
      sha256 = "1zw2f083x8z3sqyqfs1mak69db017kiclbk2pgjhcqml45737fnh";
    };

    # Requires at least PySCF
    doCheck = pyscf != null;

    checkInputs = [ pytest openssh ];

    checkPhase = ''
      export PYSISRC=${pysisrc}
      export PATH=$PATH:${binSearchPath}
      export OMPI_MCA_rmaps_base_oversubscribe=1
      echo $PYSISRC
      ${if fullTest
          then "pytest -v tests --disable-warnings"
          else "pytest -v --pyargs pysisyphus.tests --disable-warnings"
      }
    '';

    postInstall = if lib.lists.all (x: x == null) [ gaussian openmolcas orca psi4 xtb multiwfn jmol ]
      then "" else ''
      mkdir -p $out/share/pysisyphus
      cp ${pysisrc} $out/share/pysisyphus/pysisrc
      for exe in $out/bin/*; do
        wrapProgram $exe \
          --prefix PATH : ${binSearchPath} \
          --set-default "PYSISRC" "$out/share/pysisyphus/pysisrc"
      done
    '';

    meta = with lib; {
      description = "Python suite for optimization of stationary points on ground- and excited states PES and determination of reaction paths";
      homepage = "https://github.com/eljost/pysisyphus";
      license = licenses.gpl3;
      platforms = platforms.linux;
      maintainers = [ maintainers.sheepforce ];
    };
  }
