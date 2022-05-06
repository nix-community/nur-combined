# To reference hostname1's wireguard password, do:
# secrets.hostname1.wireguard.password
# If it is on a string just enclose it in ${}
{
  hostname1= {
    wireguard = {
      password = "";
      privatekeys = {
        njord = "";
        tyr = "";
      };
    };
  };
  hostname2 = {
    wireguard = {
      privatekeys = {
        njord = "";
        tyr = "";
      };
    };
  };
}
