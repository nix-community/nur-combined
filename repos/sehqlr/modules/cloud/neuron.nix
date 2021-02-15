{ config, pkgs, ... }:
{
    # systemd service
    systemd.services.neuron-sehqlr = let
      notesDir = pkgs.fetchFromGitHub {
          owner = "sehqlr";
          repo = "zettelkasten";
          rev = "main";
          sha256 = "1zyx1wyxb2lz7i2xx2js6kv92if4gg934prk45aaawfh17a39g03";
      };
    in {
        description = "Neuron web service for sehqlr's zettelkasten";
        script = "${pkgs.neuron-notes}/bin/neuron -d ${notesDir} rib -ws 0.0.0.0:8080";
    };
}