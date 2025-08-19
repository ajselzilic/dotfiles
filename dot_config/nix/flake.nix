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
	        pkgs.nodejs_22
	        pkgs.wezterm
	        pkgs.neovim
	        pkgs.neofetch

	        pkgs.docker
	        pkgs.colima
	        pkgs.lazydocker

          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.k3d
          pkgs.skaffold
          pkgs.devspace
          pkgs.k9s

	        pkgs.jetbrains.webstorm

	        pkgs.logseq
	        pkgs.raycast
	        pkgs.telegram-desktop
	        pkgs.thunderbird
          pkgs.qbittorrent
          pkgs.vlc-bin
        ];

      nixpkgs.config.allowBroken = true;
      nixpkgs.config.allowUnfree = true;

      # system.activationScripts.extraActivation.text = ''
    	#   softwareupdate --install-rosetta --agree-to-license
  	  # '';
      
      homebrew = {
        enable = true;

        brews = [
          "mas"
          "pnpm"
          "uv"
        ];

        casks = [
          "obsidian"
          "nikitabobko/tap/aerospace"
        ];

        # Uncomment to install app store apps using mas-cli.
        # masApps = {
        #   "Session" = 1521432881;
        # };

        # Uncomment to remove any non-specified homebrew packages.
        # onActivation.cleanUp = "zap";

        # Uncomment to automatically update Homebrew and upgrade packages.
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

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            # enableRosetta = true;

            user = "ajsel";

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-services" = homebrew-services;
            };

            # Optional: Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = true;

	    autoMigrate = true;
          };
        }
      ];
    };
  };
}
