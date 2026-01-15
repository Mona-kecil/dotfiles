{
  description = "monakecil's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Helper to create home configuration for different systems
      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home.nix ];
      };
    in
    {
      homeConfigurations = {
        # Linux
        "monakecil@linux" = mkHome "x86_64-linux";

        # macOS Intel
        "monakecil@macos-intel" = mkHome "x86_64-darwin";

        # macOS Apple Silicon
        "monakecil@macos-arm" = mkHome "aarch64-darwin";
      };
    };
}
