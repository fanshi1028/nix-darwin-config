{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          ids.gids.nixbld = 30000;

          users = {
            knownUsers = [ "fanshi" ];
            users.fanshi = {
              uid = 503;
              shell = pkgs.fish;
            };
          };

          programs = {
            fish.enable = true;
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
          environment.systemPackages = with pkgs; [
            vim
            cachix
            git
            emacs-pgtk
            localsend
            nix-output-monitor
            ripgrep
            yt-dlp
            zstd
            nixfmt-rfc-style
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "x86_64-darwin";
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
