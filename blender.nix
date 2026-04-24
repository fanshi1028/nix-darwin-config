{
  lib,
  stdenv,
  fetchurl,
  undmg,
  unzip,
}:

let
  inherit (stdenv.hostPlatform) system;
  pname = "blender";
  version = "5.1.1";
  appname = "Blender";
in
lib.throwIfNot (system == "aarch64-darwin") "expected aarch64-darwin" (
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://download.blender.org/release/Blender${lib.versions.majorMinor version}/blender-${version}-macos-arm64.dmg";
      sha256 = "sha256-/2IZs6qrTZrfVIuaMrOzF2T+dAtsdB0WZgxcD0/+mEE=";
    };

    nativeBuildInputs = [ undmg ];
    buildInputs = [ unzip ];
    unpackCmd = ''
      echo "File to unpack: $curSrc"
      if ! [[ "$curSrc" =~ \.dmg$ ]]; then return 1; fi
      mnt=$(mktemp -d -t ci-XXXXXXXXXX)

      function finish {
        echo "Detaching $mnt"
        /usr/bin/hdiutil detach $mnt -force
        rm -rf $mnt
      }
      trap finish EXIT

      echo "Attaching $mnt"
      /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

      echo "What's in the mount dir"?
      ls -la $mnt/

      echo "Copying contents"
      shopt -s extglob
      DEST="$PWD"
      (cd "$mnt"; cp -a !(Applications) "$DEST/")
    '';
    phases = [
      "unpackPhase"
      "installPhase"
    ];

    sourceRoot = "${appname}.app";

    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -a ./. "$out/Applications/${appname}.app/"
    '';

    meta = with lib; {
      description = "Open-source 3D creation and modeling suite (macOS prebuilt)";
      homepage = "https://www.blender.org";
      license = licenses.gpl2Only;
      platforms = [ "aarch64-darwin" ];
      maintainers = [ ];
    };
  }
)
