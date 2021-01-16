{callPackage, fetchFromGitHub, lib}:
let
	girs = fetchFromGitHub {
		"owner"= "nemequ";
		"repo"= "vala-girs";
		"rev"= "f961f482400a1118ceebbcbfc1cb474c4b8102f0";
		"sha256"= "0r1v2k1cl90z3ljaxs5np9wiif2yqpivqr7b1rqxrg70ygg4vdnk";
		"fetchSubmodules"= false;
	};
	ts-for-gjs = callPackage ../lib/ts-for-gjs {};
in
(ts-for-gjs {
	name = "gtk-typescript-defs";
	sources = [(girs + "/gir-1.0")];
}).override {
	meta = {
		description = "A set of typescript definitions for coding with gtk. Built from https://github.com/sammydre/ts-for-gjs";
		license = lib.licenses.lgpl2Plus;
	};
}