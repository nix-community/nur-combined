{ capstone, fetchurl }:

# Pin to < 4; for now can just change source used
capstone.overrideAttrs (o: rec {
   name    = "capstone-${version}";
   version = "3.0.5";
 
   src = fetchurl {
     url    = "https://github.com/aquynh/capstone/archive/${version}.tar.gz";
     sha256 = "1wbd1g3r32ni6zd9vwrq3kn7fdp9y8qwn9zllrrbk8n5wyaxcgci";
   };
})
 

