# NOTE: https://github.com/NixOS/nixpkgs/issues/411190#issuecomment-2920245758
# NOTE: Adapted from https://github.com/r17x/universe/blob/2c467d0c5c7666304aa9f87a3148b1eb09d8eac2/nix/overlays/mac-pkgs/obs-studio.nix#L38
{
  lib,
  stdenv,
  fetchurl,
  undmg,
  unzip,
}:

let
  inherit (stdenv.hostPlatform) system;
  pname = "obs-studio";
  version = "32.1.0";
  appname = "OBS";
in
lib.throwIfNot (system == "aarch64-darwin") "expected aarch64-darwin" (
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://cdn-fastly.obsproject.com/downloads/${pname}-${version}-macos-apple.dmg";
      sha256 = "sha256-pdw1B74WG+zvXK2BEsSs0WjLw3yA/BhrZu1FO36fT8U=";
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
  }
)
