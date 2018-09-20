{ stdenv, seahorn }:

# Not really a package, maybe more appropriate as a shell.nix-style thing?

stdenv.mkDerivation {
  name = "seahorn-demo";

  src = ./.;

  buildInputs = [ seahorn ];

  buildCommand = ''
    LOG_DIR=$out/share/seahorn-demo
    mkdir -p $LOG_DIR

    sea pf --horn-stats ${./seahorn_example.c} |& tee $LOG_DIR/false.log

    sea pf --horn-stats ${./seahorn_example_fixed.c} |& tee $LOG_DIR/true.log
  '';
}
