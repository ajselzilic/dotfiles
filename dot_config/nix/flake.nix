{
  description = "macbook pro system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services, ... }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [
	        pkgs.git
          pkgs.ripgrep
          pkgs.awscli2
	        pkgs.nodejs_22
          pkgs.uv
	        pkgs.fastfetch
          pkgs.ffmpeg

	        pkgs.wezterm
	        pkgs.neovim
	        pkgs.docker
	        pkgs.colima
	        pkgs.lazydocker
          pkgs.k9s

          # pkgs.kubectl
          # pkgs.kubernetes-helm
          # pkgs.k3d
          # pkgs.skaffold
          # pkgs.devspace

	        pkgs.jetbrains.webstorm
          # pkgs.jetbrains.rider

	        pkgs.raycast
	        pkgs.telegram-desktop
	        pkgs.thunderbird
          pkgs.qbittorrent
          pkgs.vlc-bin
          pkgs.syncthing
        ];

      nixpkgs.config.allowBroken = true;
      nixpkgs.config.allowUnfree = true;

      homebrew = {
        enable = true;

        brews = [
          "mas"
          "wireguard-tools"
          "pnpm"
          "postgresql"
        ];

        casks = [
          "obsidian"
          "nikitabobko/tap/aerospace"
          "battery"
        ];

        # masApps = {
        #   "Session" = 1521432881;
        # };

        onActivation.cleanup = "zap";

        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };

      nix.settings.experimental-features = "nix-command flakes";

      system.primaryUser = "ajsel";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 6;

      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults = {
        dock.autohide  = true;
        dock.magnification = false;
        dock.mineffect = "genie";
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled  = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.InitialKeyRepeat = 15;
        trackpad.Clicking = true;
      };
    };
  in
  {
    darwinConfigurations."macbookpro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "ajsel";

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-services" = homebrew-services;
            };

            mutableTaps = true;
	          autoMigrate = true;
          };
        }
      ];
    };
  };
}
