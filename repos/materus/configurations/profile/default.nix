{
  osProfile = {
    imports = [
      ./os
      ./common
    ];
  };

  homeProfile = {
    imports = [
      ./common
      ./home
    ];
  };

}