{ lib, pkgs, ... }:
let
  fetchDataZip = { urls, hash, ... }: pkgs.fetchzip {
    inherit urls hash;
    stripRoot = false;
    postFetch = ''
      mkdir $TMPDIR/data/
      mv $out/* $TMPDIR/data/
      mv $TMPDIR/data $out/
    '';
  };
in
{
  datasets.mpi-sintel-full-zip = ({ config, ... }: {
    urls = [
      "http://files.is.tue.mpg.de/sintel/MPI-Sintel-complete.zip"
      "http://sintel.cs.washington.edu/MPI-Sintel-complete.zip"
    ];
    hash = "sha256-vcgKu+auE/lvaqAuBNmKJRwBfAJUCAZqACBM0scQTF8=";
    cid = "QmSEdXWUDdEmVaLVWfnKtLwjrGSyimjJz3rtwVbZwtxPwG";
    package = pkgs.fetchzip { inherit (config) urls hash; };
  });
  datasets.mpi-sintel-full = ({ config, ... }: {
    urls = [
      "http://files.is.tue.mpg.de/sintel/MPI-Sintel-complete.zip"
      "http://sintel.cs.washington.edu/MPI-Sintel-complete.zip"
    ];
    hash = "sha256-f4odHey4tiumJruNQyPfeqUTygdIAgr5xgk42pvn724=";
    cid = "QmSEdXWUDdEmVaLVWfnKtLwjrGSyimjJz3rtwVbZwtxPwG";
    package = fetchDataZip config;
  });
  datasets.mpi-sintel-training-images = ({ config, ... }: {
    urls = [
      "http://files.is.tue.mpg.de/sintel/MPI-Sintel-training_images.zip"
      "http://sintel.cs.washington.edu/MPI-Sintel-training_images.zip"
    ];
    hash = "sha256-IA1f62XJnphgoFCPc7EI8HzlN/JaxZEWh6kUvV+Gw80=";
    cid = "Qmdhcf82Kn5ky9MNL2grNFxkHsDu977tU8dKmaUW5RRo6A";
    package = fetchDataZip config;
  });
  datasets.mpi-sintel-testing = ({ config, ... }: {
    urls = [
      "http://files.is.tue.mpg.de/sintel/MPI-Sintel-testing.zip"
      "http://sintel.cs.washington.edu/MPI-Sintel-testing.zip"
    ];
    hash = "sha256-S7DGNtF7lJKTKIOwrR9q/cIhCNR8hqNEHz4uWpj309I=";
    cid = "QmQKZJUuqcWc7gL6wRw3QCtRQuNhYzSquTG6kK7NYDDa3E";
    package = fetchDataZip config;
  });
}
