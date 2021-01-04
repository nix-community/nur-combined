{ llvmPackages_11
, lib
, fetchFromGitHub
, cmake
, libmysqlclient
, git
, boost
, readline
, bzip2
# version specifics
, version
, owner ? "TrinityCore"
, repo ? "TrinityCore"
, rev ? version
, sha256
# genrev
, branch ? "master"
, commit
, ...
}:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "TrinityCore";
  inherit version;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };

  postPatch = ''
    substituteInPlace cmake/genrev.cmake \
      --replace "set(rev_hash \"unknown\")" "set(rev_hash \"${commit}\")" \
      --replace "set(rev_branch \"Archived\")" "set(rev_branch \"${branch}\")"
  '';

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  cmakeFlags = [
    "-DMYSQL_HOME=${libmysqlclient}/lib/mysql"
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
  ];

  postInstall = ''
    cp -Rv ../sql $out/sql
  '';

  meta = with lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
