{calligra, fetchFromGitHub}:
calligra.overrideAttrs (old: {
	src = fetchFromGitHub {
		owner = "cwyc";
		repo = "calligra";
		rev = "1d545ee75f8ffb2df650e7c02e5b10a92e8c33bf";
		sha256 = "0canzz8vrbw13z08xsx4g9kjsad4aawisqzlmqfx410zl9nypp35";
		fetchSubmodules = true;
	};
	meta.description = "My patches to the calligra office suite";
	meta.broken = true; #patch conflict
})