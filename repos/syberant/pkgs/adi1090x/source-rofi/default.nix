{ fetchFromGitHub }:

let repo = fetchFromGitHub {
	owner = "adi1090x";
	repo = "rofi";
	rev = "3fdc3f352f4bf31503cd1a10f188a97009e8d31a";
	sha256 = "0cnh7szwkj1rjva7yms8m5p08amhfb3i74vqcv44ais6szdq0nlr";
  };
in repo
