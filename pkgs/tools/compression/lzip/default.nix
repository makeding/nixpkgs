{ lib, stdenv, fetchurl }:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "lzip";
  version = "1.23";
  outputs = [ "out" "man" "info" ];

  src = fetchurl {
    url = "mirror://savannah/lzip/${pname}-${version}.tar.gz";
    sha256 = "sha256-R5LAR93xXvKdVbqOaKGiHgy3aS2H7N9yBEGYZFgvKA0=";
  };

  configureFlags = [
    "CPPFLAGS=-DNDEBUG"
    "CFLAGS=-O3"
    "CXXFLAGS=-O3"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  setupHook = ./lzip-setup-hook.sh;

  doCheck = true;
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://www.nongnu.org/lzip/lzip.html";
    description = "A lossless data compressor based on the LZMA algorithm";
    license = lib.licenses.gpl2Plus;
    maintainers = with maintainers; [ vlaci ];
    platforms = lib.platforms.all;
  };
}
