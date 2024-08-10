{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation {
  pname = "mp4fpsmod";
  version = "0.27-unstable-2023-12-30";

  src = fetchFromGitHub {
    owner = "nu774";
    repo = "mp4fpsmod";
    rev = "e2dd065012f4d2c7e42d4acdefee2ffdc50d3d86";
    hash = "sha256-54pkjlvLLi4pLlQA/l+v4Mx5HlloR6GiB2GP71A0x/g=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  enableParallelBuilding = true;

  preConfigure = ''
    ./bootstrap.sh
  '';

  meta = {
    description = "Tiny mp4 time code editor";
    longDescription = ''
      Tiny mp4 time code editor. You can use this for changing fps,
      delaying audio tracks, executing DTS compression, extracting
      time codes of mp4.
    '';
    homepage = "https://github.com/nu774/mp4fpsmod";
    license = with lib.licenses; [
      # All files are distributed as Public Domain, except for the followings:
      mpl11 # mp4v2
      boost # Boost
      bsd2 # FreeBSD CVS
    ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ huggy ];
  };
}
