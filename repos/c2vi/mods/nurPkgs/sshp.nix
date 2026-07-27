{ stdenv
, fetchFromGitHub
, lib
, pkgs
, ssh ? pkgs.openssh
}:

stdenv.mkDerivation rec {
	pname = "sshp";
  version = "master";

	src = fetchFromGitHub {
		owner = "bahamas10";
		repo = "sshp";
    rev = "69b02f3110c8f3a280eb07b44a80421ddd6c5812";
    sha256 = "sha256-E7nt+t1CS51YG16371LEPtQxHTJ54Ak+r0LP0erC9Mk=";
	};

  nativeBuildInputs = [
  ];
  
  propagatedBuildInputs = [
    ssh
  ];

  installPhase = ''
    mkdir -p $out/man/man1
    mkdir -p $out/bin

	  cp man/sshp.1 $out/man/man1
	  cp sshp $out/bin
  '';


  meta = with lib; {
    description = "Parallel SSH Executor ";
    longDescription = ''
      from: https://github.com/bahamas10/sshp
      video: https://www.youtube.com/watch?v=m_Gr0510IHc
      
      sshp manages multiple ssh processes and handles coalescing the output to the terminal. By default, sshp will read a file of newline-separated hostnames or IPs and fork ssh subprocesses for them, redirecting the stdout and stderr streams of the child line-by-line to stdout of sshp itself.
    '';
    homepage = "https://github.com/bahamas10/sshp";
    license = licenses.mit;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
