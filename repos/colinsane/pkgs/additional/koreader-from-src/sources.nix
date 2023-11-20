# to update:
# - first, figure the rev for `koreader-base`:
#   - inside `koreader` repo:
#     - `git submodule status base`
#     - or `git log base`
# - inside `koreader-base` repo:
#   - `git diff old-rev..new-rev thirdparty`
# - update `source.rev` everywhere here that changed upstream
#   - zero the hashes here and correct them based on build errors
# - tweak ./vendor-external-projects.patch until it applies
#   - usually just upstream changed a URL or something minor
#
# a full rebuild takes approximately 10 minutes on a mid-range desktop
#
# the following build output may look like an error, but is safe to ignore:
# - "awk: fatal: cannot open file `3.9' for reading: No such file or directory"
#   - this number comes from the luarocks version
#
# how to automate koreader updates?
# - it may be that koreader-base is more strongly decoupled from `koreader` than first appears:
#   - most `koreader` commits which update base simply bump its rev and nothing more.
#   - then, `koreader-base` could be its own package, updated independently from the main koreader.
{
  thirdparty = {
    curl = {
      source.url = "https://github.com/curl/curl.git";
      source.rev = "tags/curl-7_80_0";
      source.hash = "sha256-kzozc0Io+1f4UMivSV2IhzJDQXmad4wNhXN/Y2Lsg3Q=";
    };
    czmq = {
      source.url = "https://github.com/zeromq/czmq.git";
      source.rev = "2a0ddbc4b2dde623220d7f4980ddd60e910cfa78";
      source.hash = "sha256-p4Cl2PLVgRQ0S4qr3VClJXjvAd2LUBU9oRUvOCfVnyw=";
    };
    djvulibre = {
      source.url = "https://gitlab.com/koreader/djvulibre.git";
      source.rev = "6a1e5ba1c9ef81c205a4b270c3f121a1e106f4fc";
      source.hash = "sha256-OWSbxdr93FH3ed0D+NSFWIah7VDTcL3LIGOciY+f4dk=";
    };
    fbink = {
      source.url = "https://github.com/NiLuJe/FBInk.git";
      source.rev = "ae9dd275de369b1b34e1b566bca29573f06f38a2";
      source.hash = "sha256-wkyl9xtw9ocjGGArvfGa1qjamwgywPktnZJNfdychB0=";
    };
    freetype2 = {
      source.url = "https://gitlab.com/koreader/freetype2.git";
      source.rev = "VER-2-13-2";
      source.hash = "sha256-yylSmVM3D5xnbFx9qEEHFIP/K0x/WDXZr0MA4C7ng7k=";
    };
    fribidi = {
      source.url = "https://github.com/fribidi/fribidi.git";
      source.rev = "tags/v1.0.12";
      source.hash = "sha256-L4m/F9rs8fiv9rSf8oy7P6cthhupc6R/lCv30PLiQ4M=";
    };
    giflib = {
      source.url = "https://gitlab.com/koreader/giflib.git";
      source.rev = "5.1.4";
      source.hash = "sha256-znbY4tliXHXVLBd8sTKrbglOdCUb7xhcCQsDDWcQfhw=";
    };
    glib = {
      source.url = "https://github.com/GNOME/glib.git";
      source.rev = "2.58.3";
      source.hash = "sha256-KmJXCJ6h2QhPyK1axk+Y9+yJzO0wnCczcogopxGShJc=";
    };
    harfbuzz = {
      source.url = "https://github.com/harfbuzz/harfbuzz.git";
      source.rev = "8.2.1";
      source.hash = "sha256-1JgOXpObptt/IOkYj3Q9K170Yd5DIoBa20eoqY/iY6M=";
    };
    kobo-usbms = {
      source.url = "https://github.com/koreader/KoboUSBMS.git";
      source.rev = "3daab316d3aff2b43ced9c0b18e6ecdeec953e4a";
      source.hash = "sha256-iBbbKCpi0/velkX91Qju0oXLZtRYGesbra1huKnGQFE=";
    };
    leptonica = {
      source.url = "https://github.com/DanBloomberg/leptonica.git";
      source.rev = "1.74.1";
      source.hash = "sha256-SDXKam768xvZZvTbXe3sssvZyeLEEiY97Vrzx8hoc6g=";
    };
    libjpeg-turbo = {
      source.url = "https://github.com/libjpeg-turbo/libjpeg-turbo.git";
      source.rev = "3.0.0";
      source.hash = "sha256-mIeSBP65+rWOCRS/33MPqGUpemBee2qR45CZ6H00Hak=";
    };
    libk2pdfopt = {
      source.url = "https://github.com/koreader/libk2pdfopt.git";
      source.rev = "60b82eeecf71d1776951da970fe8cd2cc5735ded";
      source.hash = "sha256-9UcDr9e4GZCZ78moRs1ADAt4Xl7z3vR93KDexXEHvhw=";
    };
    libpng = {
      source.url = "https://github.com/glennrp/libpng.git";
      source.rev = "v1.6.40";
      source.hash = "sha256-Rad7Y5Z9PUCipBTQcB7LEP8fIVTG3JsnMeknUkZ/rRg=";
    };
    libunibreak = {
      source.url = "https://github.com/adah1972/libunibreak.git";
      source.rev = "tags/libunibreak_5_1";
      source.hash = "sha256-hjgT5DCQ6KFXKlxk9LLzxGHz6B71X/3Ot7ipK3KY85A=";
    };
    libwebp = {
      source.url = "https://github.com/webmproject/libwebp.git";
      source.rev = "v1.3.2";
      source.hash = "sha256-gfwUlJ44biO1lB/3SKfMkM/YBiYcz6RqeMOw+0o6Z/Q=";
    };
    libzmq = {
      source.url = "https://github.com/zeromq/libzmq";
      source.rev = "883e95b22e0bffffa72312ea1fec76199afbe458";
      source.hash = "sha256-R76EREtHsqcoKxKrgT8gfEf9pIWdLTBXvF9cDvjEf3E=";
    };
    lj-wpaclient = {
      source.url = "https://github.com/koreader/lj-wpaclient.git";
      source.rev = "2f93beb3071e6ebb57c783bd5b92f83aa5ebb757";
      source.hash = "sha256-ilJviGZTvL2i1TN5lHQ4eA9pFiM7NlXD+v9ofv520b8=";
      machineAgnostic = true;
    };
    lodepng = {
      source.url = "https://github.com/lvandeve/lodepng.git";
      source.rev = "c18b949b71f45e78b1f9a28c5d458bce0da505d6";
      source.hash = "sha256-AAw6I+MxDaxmGpjC5efxuBNw7Lx8FXwg2TEfl6LfPfQ=";
    };
    lua-htmlparser = {
      source.url = "https://github.com/msva/lua-htmlparser";
      source.rev = "5ce9a775a345cf458c0388d7288e246bb1b82bff";
      source.hash = "sha256-aSTLSfqz/MIDFVRwtBlDNBUhPb7KqOl32/Y62Hdec1s=";
    };
    luajit = {
      source.url = "https://github.com/LuaJIT/LuaJIT";
      source.rev = "656ecbcf8f669feb94e0d0ec4b4f59190bcd2e48";
      source.hash = "sha256-KPZ1jaU9qu7CUg2eHxBNu2mrHD54+lNOCQB4sb1DPok=";
    };
    lua-rapidjson = {
      source.url = "https://github.com/xpol/lua-rapidjson";
      source.rev = "242b40c8eaceb0cc43bcab88309736461cac1234";
      source.hash = "sha256-y/czEVPtCt4uN1n49Qi7BrgZmkG+SDXlM5D2GvvO2qg=";
    };
    luasec = {
      source.url = "https://github.com/brunoos/luasec";
      source.rev = "tags/v1.3.1";
      source.hash = "sha256-3iYRNQoVk5HFjDSqRRmg1taSqeT2cHFil36vxjrEofo=";
    };
    luasocket = {
      source.url = "https://github.com/lunarmodules/luasocket";
      source.rev = "8c2ff7217e2a205eb107a6f48b04ff1b2b3090a1";
      source.hash = "sha256-Y35QYNLznQmErr6rIjxLzw0/6Y7y8TbzD4yaEdgEljA=";
    };
    lua-Spore = {
      # Complete... ish?
      # this originally failed like so:
      #   Missing dependencies for lua-spore 0.3.1-1:
      #   luajson >= 1.3 (not installed)
      # it passes now only because we patch out its build-time check for luajson (which we DO provide at runtime)
      source.url = "https://framagit.org/fperrad/lua-Spore";
      source.rev = "tags/0.3.3";
      source.hash = "sha256-wb7ykJsndoq0DazHpfXieUcBBptowYqD/eTTN/EK/6g=";
    };
    lunasvg = {
      source.url = "https://github.com/sammycage/lunasvg.git";
      source.rev = "59d6f6ba835c1b7c7a0f9d4ea540ec3981777885";
      source.hash = "sha256-gW2ikakS6Omz5upmy26nAo/jkGHYO2kjlB3UmKJBh1k=";
    };
    minizip = {
      source.url = "https://github.com/nmoinvaz/minizip";
      source.rev = "0b46a2b4ca317b80bc53594688883f7188ac4d08";
      source.hash = "sha256-P/3MMMGYDqD9NmkYvw/thKpUNa3wNOSlBBjANHSonAg=";
    };
    mupdf = {
      source.url = "https://github.com/ArtifexSoftware/mupdf.git";
      source.rev = "tags/1.13.0";
      source.hash = "sha256-pQejRon9fO9A1mhz3oLjBr1j4HveDLcQIWjR1/Rpy5Q=";
    };
    nanosvg = {
      source.url = "https://github.com/memononen/nanosvg.git";
      source.rev = "9da543e8329fdd81b64eb48742d8ccb09377aed1";
      source.hash = "sha256-VOiN6583DtzGYPRkl19VG2QvSzl4T9HaynBuNcvZf94=";
      machineAgnostic = true;
    };
    openssh = {
      source.url = "https://github.com/openssh/openssh-portable.git";
      source.rev = "V_8_6_P1";
      source.hash = "sha256-yjIpSbe5pt9sEV2MZYGztxejg/aBFfKO8ieRvoLN2KA=";
    };
    openssl = {
      source.url = "https://github.com/openssl/openssl.git";
      source.rev = "OpenSSL_1_1_1u";
      source.hash = "sha256-JOcUj4ovA6621+1k2HUsvhGX1B9BjvaMbCaSx680nSs=";
    };
    popen-noshell = {
      source.url = "https://github.com/famzah/popen-noshell.git";
      source.rev = "e715396a4951ee91c40a98d2824a130f158268bb";
      source.hash = "sha256-JeBZMsg6ZUGSnyZ4eds4w63gM/L73EsAnLaHOPpL6iM=";
    };
    # sdcv = {
    #   # upstream is (temporarily?) acquiring this via `download_project` machinery
    #   source.url = "https://github.com/Dushistov/sdcv.git";
    #   source.rev = "v0.5.5"
    #   # source.rev = "6e36e7730caf07b6cd0bfa265cdf9b5e31e7acad";
    #   # source.hash = "sha256-pPaT9tB39dd+VyE21KSjMpON99KjOxQ8Hi8+ZgFsuUY=";
    # };
    tesseract = {
      source.url = "https://github.com/tesseract-ocr/tesseract.git";
      source.rev = "60176fc5ae5e7f6bdef60c926a4b5ea03de2bfa7";
      source.hash = "sha256-FQvlrJ+Uy7+wtUxBuS5NdoToUwNRhYw2ju8Ya8MLyQw=";
    };
    turbo = {
      source.url = "https://github.com/kernelsauce/turbo";
      source.rev = "tags/v2.1.3";
      source.hash = "sha256-vBRkFdc5a0FIt15HBz3TnqMZ+GGsqjEefnfJEpuVTBs=";
    };
    utf8proc = {
      source.url = "https://github.com/JuliaStrings/utf8proc.git";
      source.rev = "v2.8.0";
      source.hash = "sha256-/lSD78kj133rpcSAOh8T8XFW/Z0c3JKkGQM5Z6DcMtU=";
    };
    zstd = {
      source.url = "https://github.com/facebook/zstd.git";
      source.rev = "tags/v1.5.5";
      source.hash = "sha256-tHHHIsQU7vJySrVhJuMKUSq11MzkmC+Pcsj00uFJdnQ=";
    };
    zsync2 = {
      source.url = "https://github.com/NiLuJe/zsync2.git";
      source.rev = "e618d18f6a7cbf350cededa17ddfe8f76bdf0b5c";
      source.hash = "sha256-S0vxCON1l6S+NWlnRPfm7R07DVkvkG+6QW5LNvXBlA8=";
    };
  };

  externalProjects = {
    dropbear = {
      url = "http://deb.debian.org/debian/pool/main/d/dropbear/dropbear_2018.76.orig.tar.bz2";
      hash = "sha256-8vuRZ+yoz5NFal/B1Pr3CZAqOrcN1E41LzrLw//a6mU=";
    };
    gettext = {
      url = "http://ftpmirror.gnu.org/gettext/gettext-0.21.tar.gz";
      hash = "sha256-x30NoxAq7JwH9DZx5gYR6/+JqZbvFZSXzo5Z0HV4axI=";
    };
    libffi = {
      url = "https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz";
      hash = "sha256-1mxWrSWags8qnfxAizK/XaUjcVALhHRff7i2RXEt9nY=";
    };
    libiconv = {
      url = "http://ftpmirror.gnu.org/libiconv/libiconv-1.15.tar.gz";
      hash = "sha256-zPU2YgpFRY0muoOIepg7loJwAekqE4R7ReSSXMiRMXg=";
    };
    lpeg = {
      url = "http://distcache.FreeBSD.org/ports-distfiles/lpeg-1.0.2.tar.gz";
      hash = "sha256-SNZldgUbbHg4j6rQm3BJMJMmRYj80PJY3aqxzdShX/4=";
    };
    sdcv = {
      # TODO: if this form of substitution works, i could optionally patch in *all* deps
      # using the `file://@foo@` ExternalProject_Add syntax
      url = "https://github.com/Dushistov/sdcv/archive/v0.5.5.tar.gz";
      hash = "sha256-TSUZ6PhHm5MB3JHpzaPh7v7xmXDs4OjAXwx7et5dyUs=";
    };
    sdl2 = {
      url = "https://github.com/libsdl-org/SDL/releases/download/release-2.28.1/SDL2-2.28.1.tar.gz";
      hash = "sha256-SXfOulwAVNvmwvEUZBrO1DzjvytB6mS2o3LWuhKcsV0=";
    };
    sqlite = {
      url = "https://www.sqlite.org/2023/sqlite-autoconf-3430200.tar.gz";
      hash = "sha256-bUIrb2LE3iyoDWGGDjo/tpNVTS91uxqsp0PMxNb2CfA=";
    };
    tar = {
      url = "http://ftpmirror.gnu.org/tar/tar-1.34.tar.gz";
      hash = "sha256-A9kIz1doz+a3rViMkhxu0hrKv7K3m3iNEzBFNQdkeu0=";
    };
    zlib = {
      url = "https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.xz";
      hash = "sha256-0Uw44xOvw1qah2Da3yYEL1HqD10VSwYwox2gVAEH+5g=";
    };
  };
}
