{
  description = "Fanshi1028's nix-darwin system flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    kmonad.url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
    kmonad.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-unstable,
      kmonad,
      emacs-overlay,
    }:
    let
      system = "aarch64-darwin";
      kmonad-exe = kmonad.packages."${system}".default;
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
          environment.systemPackages =
            (
              with pkgs;
              [
                mpv
                vim
                cachix
                git
                # NOTE: Latest emacs for mac dictation
                # https://xenodium.com/macos-dictation-returns-to-emacs-fix-merged
                (import nixpkgs {
                  inherit system;
                  overlays = [ emacs-overlay.overlays.default ];
                }).emacs-git-pgtk
                localsend
                nix-output-monitor
                ripgrep
                zstd
                nixfmt-rfc-style
                ffmpeg
                emacs-lsp-booster
                python313Packages.huggingface-hub
              ]
              # default env to for using cabal inti to quick start haskell project
              ++ [
                haskell.compiler.ghc9122
                cabal-install
              ]
              ++ lib.optionals (system == "aarch64-darwin") [
                (callPackage ./obs-studio.nix { })
              ]
            )
            ++ (with import nixpkgs-unstable { inherit system; }; [
              yt-dlp

              (llama-cpp.overrideAttrs ({
                version = "8505";
                src = fetchFromGitHub {
                  owner = "ggml-org";
                  repo = "llama.cpp";
                  tag = "b8505";
                  hash = "sha256-Bg7fUTHsXcwEdemi0/T4GXB09SOx4UHZ7clN9zQ1zDA=";
                  leaveDotGit = true;
                  postFetch = ''
                    git -C "$out" rev-parse --short HEAD > $out/COMMIT
                    find "$out" -name .git -print0 | xargs -0 rm -rf
                  '';
                };
                npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
              }))
              python314Packages.mlx-lm
              stable-diffusion-cpp
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
