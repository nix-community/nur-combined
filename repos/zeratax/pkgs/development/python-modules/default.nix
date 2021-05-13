{ config, lib, pkgs, python3 }:

# can't use python3packages.newScope since it doesn't implement it
# means we have to be manually point out the deps :/
lib.makeScope pkgs.newScope (self: with self; {
    # aiofiles = python3.pkgs.callPackage ./aiofiles { };
    aiohttp-socks = python3.pkgs.callPackage ./aiohttp-socks { inherit python-socks; };
    baron = python3.pkgs.callPackage ./baron { };
    hsluv = python3.pkgs.callPackage ./hsluv { };
    # html-sanitizer = python3.pkgs.callPackage ./html-sanitizer { };
    # matrix-nio = python3.pkgs.callPackage ./matrix-nio { inherit aiohttp-socks; };
    plyer = python3.pkgs.callPackage ./plyer { };
    # pyfastcopy = python3.pkgs.callPackage ./pyfastcopy { };
    python-socks = python3.pkgs.callPackage ./python-socks { };
    redbaron = python3.pkgs.callPackage ./redbaron { inherit baron; };
    watchgod = python3.pkgs.callPackage ./watchgod { };
})
 