{
  description = "Laurence's dotfiles — macOS (nix-darwin) + Linux (home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkPackages = pkgs: import ./modules/packages.nix { inherit pkgs; };
    in
    {
      # macOS: darwin-rebuild switch --flake ~/.config/nix (alias: drs)
      darwinConfigurations."Laurences-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit self;
          packages = mkPackages (mkPkgs "aarch64-darwin");
        };
        modules = [
          ./modules/darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };

      # Linux (NUC): home-manager switch --flake ~/.config/nix#laurence@nuc (alias: hms)
      homeConfigurations."laurence@nuc" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = {
          packages = mkPackages (mkPkgs "x86_64-linux");
        };
        modules = [ ./modules/linux.nix ];
      };
    };
}
