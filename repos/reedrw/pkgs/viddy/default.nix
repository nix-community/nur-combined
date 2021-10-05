{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "viddy";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "sachaos";
    repo = "viddy";
    rev = "v${version}";
    sha256 = "18ms4kfv332863vd8b7mmrz39y4b8gvhi6lx9x5385jfzd19w5wx";
  };

  vendorSha256 = "0789wq4d9cynyadvlwahs4586gc3p78gdpv5wf733lpv1h5rjbv3";

  meta = with lib; {
    description = "A modern watch command. Time machine and pager etc.";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ reedrw ];
    platforms = platforms.linux;
  };
}
