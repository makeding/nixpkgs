{ config
, lib
, stdenv
, fetchFromGitHub
, cmake
, macdylibbundler
, makeWrapper
, darwin
, codec2
, libpulseaudio
, libsamplerate
, libsndfile
, lpcnetfreedv
, portaudio
, speexdsp
, hamlib
, wxGTK32
, pulseSupport ? config.pulseaudio or stdenv.isLinux
, AppKit
, AVFoundation
, Cocoa
, CoreMedia
}:

stdenv.mkDerivation rec {
  pname = "freedv";
  version = "1.8.7";

  src = fetchFromGitHub {
    owner = "drowe67";
    repo = "freedv-gui";
    rev = "v${version}";
    hash = "sha256-N9LZCf2YAhVgxnQWgCB9TqGNpUGP1ZqpLmbYIaQsn08=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/CMakeLists.txt \
      --replace "\''${CMAKE_SOURCE_DIR}/macdylibbundler/dylibbundler" "dylibbundler"
    sed -i "/hdiutil/d" src/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
  ] ++ lib.optionals stdenv.isDarwin [
    macdylibbundler
    makeWrapper
    darwin.autoSignDarwinBinariesHook
  ];

  buildInputs = [
    codec2
    libsamplerate
    libsndfile
    lpcnetfreedv
    speexdsp
    hamlib
    wxGTK32
  ] ++ (if pulseSupport then [ libpulseaudio ] else [ portaudio ])
  ++ lib.optionals stdenv.isDarwin [
    AppKit
    AVFoundation
    Cocoa
    CoreMedia
  ];

  cmakeFlags = [
    "-DUSE_INTERNAL_CODEC2:BOOL=FALSE"
    "-DUSE_STATIC_DEPS:BOOL=FALSE"
    "-DUNITTEST=ON"
  ] ++ lib.optionals pulseSupport [ "-DUSE_PULSEAUDIO:BOOL=TRUE" ];

  NIX_CFLAGS_COMPILE = lib.optionals (stdenv.isDarwin && stdenv.isx86_64) [
    "-DAPPLE_OLD_XCODE"
  ];

  doCheck = true;

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/FreeDV.app $out/Applications
    makeWrapper $out/Applications/FreeDV.app/Contents/MacOS/FreeDV $out/bin/freedv
  '';

  meta = with lib; {
    homepage = "https://freedv.org/";
    description = "Digital voice for HF radio";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ mvs wegank ];
    platforms = platforms.unix;
  };
}
