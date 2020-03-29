{ sources, lib, buildGoModule }:

buildGoModule rec {
  pname = "lefthook";
  version = sources.lefthook.rev;

  src = sources.lefthook;

  modSha256 = "0mjhw778x40c2plmjlkiry4rwvr9xkz65b88a61j86liv2plbmq2";

  meta = with lib; {
    inherit (sources.lefthook) homepage description;
    license = licenses.mit;
    maintainers = with maintainers; [ rencire ];
  };
}

