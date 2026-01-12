{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      system = "x86_64-darwin";
      configuration =
        { pkgs, ... }:
        {
          ids.gids.nixbld = 30000;

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

          environment.variables = {
            EDITOR = "vim";
          };
          environment.systemPackages =
            with pkgs;
            [
              vim
              cachix
              git
              emacs-pgtk
              localsend
              nix-output-monitor
              ripgrep
              zstd
              nixfmt-rfc-style
            ]
            ++ (with import nixpkgs-unstable { inherit system; }; [ yt-dlp ]);

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = system;
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Francis
      darwinConfigurations.Francis = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
