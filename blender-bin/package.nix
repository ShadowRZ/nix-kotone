{
  pname,
  version,
  src,
}:

{
  SDL2,
  alsa-lib,
  blender,
  lib,
  libGLU,
  libdecor,
  libdrm,
  libglvnd,
  libice ? xorg.libICE,
  libsm ? xorg.libSM,
  libx11 ? xorg.libX11,
  libxfixes ? xorg.libXfixes,
  libxi ? xorg.libXi,
  libxkbcommon,
  libxrender ? xorg.libXrender,
  libxxf86vm ? xorg.libXxf86vm,
  makeWrapper,
  numactl,
  ocl-icd,
  openal,
  pulseaudio,
  stdenv,
  vulkan-loader,
  wayland,
  xorg,
  zlib,
}:

let
  libs = [
    wayland
    libdecor
    libx11
    libxi
    libxxf86vm
    libxfixes
    libxrender
    libxkbcommon
    libGLU
    libglvnd
    numactl
    SDL2
    libdrm
    ocl-icd
    stdenv.cc.cc.lib
    openal
    alsa-lib
    pulseaudio
  ]
  ++ lib.optionals (lib.versionAtLeast version "3.5") [
    libsm
    libice
    zlib
  ]
  ++ lib.optionals (lib.versionAtLeast version "4.5") [ vulkan-loader ];
in

stdenv.mkDerivation {
  inherit pname version src;

  buildInputs = [ makeWrapper ];

  preUnpack = ''
    mkdir -p $out/libexec
    cd $out/libexec
  '';

  installPhase = ''
    cd $out/libexec
    mv blender-* blender

    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps
    mv ./blender/blender.desktop $out/share/applications/blender.desktop
    mv ./blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg

    mkdir $out/bin

    makeWrapper $out/libexec/blender/blender $out/bin/blender \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath libs}

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      blender/blender

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
      $out/libexec/blender/*/python/bin/python3*
  '';

  meta = {
    inherit (blender.meta)
      description
      homepage
      mainProgram
      ;
  };
}
