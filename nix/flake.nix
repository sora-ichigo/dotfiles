{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHomeConfiguration = { system, username }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          isDarwin = builtins.match ".*-darwin" system != null;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in
    {
      # 実際に使う設定（nix-setup で @USERNAME@ と @SYSTEM@ を置換）
      homeConfigurations."default" = mkHomeConfiguration {
        system = "@SYSTEM@";
        username = "@USERNAME@";
      };

      # CI 用の設定
      homeConfigurations."ci-x86_64-darwin" = mkHomeConfiguration {
        system = "x86_64-darwin";
        username = "runner";
      };

      homeConfigurations."ci-x86_64-linux" = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "runner";
      };
    };
}
