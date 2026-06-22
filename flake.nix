{
  description = "Fanshi1028's nix-darwin system flake";
  inputs = {
    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    kmonad.url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
    kmonad.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs-2511";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-2511,
      nixpkgs-unstable,
      kmonad,
      emacs-overlay,
    }:
    let
      system = "aarch64-darwin";
      kmonad-exe = kmonad.packages."${system}".default;
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
      blackhole2ch = pkgs-unstable.blackhole.override { channel = "2ch"; };
      configuration =
        { pkgs, ... }:
        let
          kmonadConfigFile = pkgs.writeText "kmonad-config.kbd" (builtins.readFile ./home-row-mod.kbd);
        in
        {
          networking = {
            knownNetworkServices = [ "Wi-Fi" ];
            dns = [
              # adguard
              "94.140.14.14"
              "94.140.15.15"
              "2a10:50c0::ad1:ff"
              "2a10:50c0::ad2:ff"
              #quad9
              "9.9.9.9"
              "149.112.112.112"
              "2620:fe::fe"
              "2620:fe::9"
              #cloudflare
              "1.1.1.1"
              "1.0.0.1"
              "2606:4700:4700::1111"
              "2606:4700:4700::1001"
              # google
              "8.8.8.8"
              "8.8.4.4"
              "2001:4860:4860::8888"
              "2001:4860:4860::8844"
            ];
          };
          programs = {
            fish = {
              enable = true;
              promptInit = ''
                ${builtins.readFile ./fish/fish_prompt.fish}
                ${builtins.readFile ./fish/fish_right_prompt.fish}
              '';
              interactiveShellInit = "set -U fish_greeting";
            };
            direnv.enable = true;
          };

          fonts.packages = with pkgs; [
            nerd-fonts.symbols-only
            sarasa-gothic
          ];

          nix.channel.enable = false;

          nix.nixPath = [
            {
              nixpkgs = "flake:nixpkgs";
              nixpkgs-unstable = "flake:nixpkgs-unstable";
            }
          ];

          nix.extraOptions = ''
            keep-outputs = true
            keep-derivations = true
          '';

          nix.settings = {
            trusted-public-keys = [
              "fanshi1028-personal.cachix.org-1:XoynOisskxlhrHM+m5ytvodedJdAo8gKpam/L6/AmBI="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=  "
              "haskell-miso-cachix.cachix.org-1:m8hN1cvFMJtYib4tj+06xkKt5ABMSGfe8W7s40x1kQ0="
            ];
            trusted-substituters = [
              "https://fanshi1028-personal.cachix.org"
              "https://nix-community.cachix.org"
              "https://haskell-miso-cachix.cachix.org"
            ];
            extra-sandbox-paths = [
              "/private/etc/ssl/certs/"
              "/private/etc/static/ssl/certs/"
            ];
          };

          nix.registry = {
            nixpkgs = {
              flake = nixpkgs;
            };
            nixpkgs-unstable = {
              flake = nixpkgs-unstable;
            };
          };

          environment.variables = {
            EDITOR = "vim";
          };
          environment.systemPackages = [
            blackhole2ch
          ]
          ++ (
            with pkgs;
            [
              firefox
              yt-dlp
              mpv
              vim
              cachix
              git
              # NOTE: Latest emacs for mac dictation
              # https://xenodium.com/macos-dictation-returns-to-emacs-fix-merged
              (import nixpkgs-2511 {
                inherit system;
                overlays = [ emacs-overlay.overlays.default ];
              }).emacs-git-pgtk
              localsend
              nix-output-monitor
              ripgrep
              zstd
              nixfmt
              ffmpeg
              emacs-lsp-booster
              # TEMP for doom emacs env: https://github.com/doomemacs/doomemacs/issues/6612#issuecomment-4150181313
              fd
              tree
              jujutsu
              python314Packages.huggingface-hub
              python314Packages.mlx-lm
            ]
            # default env to for using cabal inti to quick start haskell project
            ++ [
              haskell.compiler.ghc9122
              cabal-install
            ]
            ++ lib.optionals (system == "aarch64-darwin") [
              (
                let
                  pname = "obs-studio";
                  version = "32.1.0";
                in
                callPackage ./mac-app.nix { } {
                  inherit pname version;
                  url = "https://cdn-fastly.obsproject.com/downloads/${pname}-${version}-macos-apple.dmg";
                  sha256 = "sha256-pdw1B74WG+zvXK2BEsSs0WjLw3yA/BhrZu1FO36fT8U=";
                  appname = "OBS";
                }
              )
              (
                let
                  pname = "blender";
                  version = "5.1.1";
                  appname = "Blender";
                in
                callPackage ./mac-app.nix { } {
                  inherit pname version appname;
                  url = "https://download.blender.org/release/${appname} ${lib.versions.majorMinor version}/${pname}-${version}-macos-arm64.dmg";
                  sha256 = "sha256-/2IZs6qrTZrfVIuaMrOzF2T+dAtsdB0WZgxcD0/+mEE=";
                }
              )
              (
                let
                  pname = "omlx";
                  version = "0.3.12";
                  appname = "oMLX";
                in
                callPackage ./mac-app.nix { } {
                  inherit pname version appname;
                  url = "https://github.com/jundot/omlx/releases/download/v${version}/${appname}-${version}-macos26-tahoe.dmg";
                  sha256 = "sha256-HaAsE1NyUymg9E1AtEC8x408z6UeOBjNx80lBMQXbJQ=";
                }
              )
              (
                let
                  pname = "ungoogled-chromium";
                  version = "147.0.7727.116-1.1";
                  appname = "Chromium";
                in
                callPackage ./mac-app.nix { } {
                  inherit pname version appname;
                  url = "https://github.com/ungoogled-software/${pname}-macos/releases/download/${version}/${pname}_${version}_arm64-macos.dmg";
                  sha256 = "sha256-w59h9xtlvnKhKeWRvH+CklHg5tONy7aRyiCdHCNk9sU=";
                }
              )

              (callPackage ./swiftlm.nix { })
              (callPackage ./draw-things-cli.nix { })
              (callPackage ./ds4.nix { })
            ]
          )
          ++ (with pkgs-unstable; [
          ]);

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = system;

          launchd.daemons.Karabiner-VirtualHIDDevice-Daemon = {
            serviceConfig = {
              Program = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/tmp/Karabiner-DriverKit-VirtualHIDDevice.log";
              StandardErrorPath = "/tmp/Karabiner-DriverKit-VirtualHIDDevice.err";
            };
          };
          # FIXME: not work due to https://github.com/kmonad/kmonad/issues/675
          # launchd.daemons.kmonad = with pkgs; {
          #   path = [ kmonad-exe ];
          #   serviceConfig = {
          #     Program = "${kmonad-exe}/bin/kmonad";
          #     ProgramArguments = [
          #       "${kmonad-exe}/bin/kmonad"
          #       "${kmonadConfigFile}"
          #     ];
          #     KeepAlive = true;
          #     RunAtLoad = true;
          #     StandardOutPath = "/tmp/kmonad.log";
          #     StandardErrorPath = "/tmp/kmonad.err";
          #     # Optional: delay startup if HID services aren't ready
          #     # throttleInterval = 5;
          #   };
          # };

          security.pam.services.sudo_local.touchIdAuth = true;

          # NOTE: https://github.com/nix-darwin/nix-darwin/issues/663#issuecomment-3192624455
          # ref: https://github.com/nix-darwin/nix-darwin/blob/06648f4902343228ce2de79f291dd5a58ee12146/modules/fonts/default.nix#L47
          system.activationScripts.extraActivation.text = ''
            printf >&2 'setting up /Library/Audio/Plug-Ins/HAL/Blackhole2ch.driver...\n'
            mkdir -p /Library/Audio/Plug-Ins/HAL

            ${pkgs.rsync}/bin/rsync \
                    --archive \
                    --copy-links \
                    --delete-during \
                    --delete-missing-args \
                    '${blackhole2ch}/Library/Audio/Plug-Ins/HAL/Blackhole2ch.driver' \
                    '/Library/Audio/Plug-Ins/HAL/'
          '';

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Francis
      darwinConfigurations.Franciss-MacBook-Pro = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
