{ config, stdenv, lib, fetchgit, boost170, cassandra, cpp-driver, libuv, openssl, mosquitto, libgcrypt, libgpg-error freeipmi, net-snmp, opencv, mariadb-connector-c }:

stdenv.mkDerivation rec {
  name =  "dcdb-${version}";
  version = "0.4";
  
  # src = fetchgit {
  #   url = "https://gitlab.bsc.es/ear_team/ear.git";
  #   rev = "d7e206ab289efdbb25a00b408dea748536faeef2";
  #   sha256 = "sha256-ff/NdZ3jvHGxO4v92+KpzDpHhWcZKVmwuBLs/oZyl5I=";
  # };

  src = /home/auguste/dev/dcdb;
  
  nativeBuildInputs = [ boost170 cassandra cpp-driver libuv openssl mosquitto libgcrypt libgpg-error freeipmi net-snmp opencv mariadb-connector-c ];
  
  preBuild = ''
    substituteInPlace Makefile --replace "include dependencies.mk" "#include dependencies.mk"
  '';
    
  # apache-cassandra-3.11.5.tar.gz
  
  #buildInputs = [ gsl slurm openmpi ] ++ [(if useMysql then  libmysqlclient else postgresql)] ++ lib.optional cudaSupport cudatoolkit;

  #patches = [ ./Makefile.extra.patch ];

  #preConfigure = (if useMysql then ''
  
  #configureFlags = [
  
  #preBuild =;

  meta = with lib; {
    homepage = "https://gitlab.lrz.de/dcdb/dcdb";
    description = "The Data Center Data Base (DCDB) is a modular, continuous and holistic monitoring framework targeted at HPC environments.";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
