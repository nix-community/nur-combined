{ llvmPackages_13
, lib
, fetchFromGitHub

# build time
, cmake
, git

# runtime
, boost
, bzip2
, icu
, libmysqlclient
, readline

# version specifics
, version
, owner ? "TrinityCore"
, repo ? "TrinityCore"
, rev ? version
, sha256

# genrev
, branch ? "master"
, commit

# patches
, extraPatches ? []
, broken ? false
, ...
}:

llvmPackages_13.stdenv.mkDerivation rec {
  pname = "TrinityCore";
  inherit version;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
    leaveDotGit = true;
  };

  patches = [] ++ extraPatches;

  postPatch = ''
    substituteInPlace cmake/genrev.cmake \
      --replace "set(rev_hash \"unknown\")" "set(rev_hash \"${commit}\")" \
      --replace "set(rev_branch \"Archived\")" "set(rev_branch \"${branch}\")"
  '';

  nativeBuildInputs = [
    cmake
    git
  ];

  buildInputs = [
    boost
    bzip2
    icu
    libmysqlclient
    readline
  ];

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
    inherit broken;
  };
}
