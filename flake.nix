{
  description = "Opencode's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, utils, ... }: 
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          config = { allowUnfree = true; };
        };
        lib = pkgs.lib;
        #defaultPkg = pkgs.callPackage ./default.nix {
        #  inherit pkgs;
        #};
      in {
        packages.default = pkgs.buildGoModule {
          pname = "opencode";
          version = "0.0.54";

          src = ./.; # Point to our source directory

          vendorHash = "sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=";

          checkFlags =
          let
            skippedTests = [
              # permission denied
              "TestBashTool_Run"
              "TestSourcegraphTool_Run"
              "TestLsTool_Run"
            ];
          in
          [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];

          meta = with pkgs.lib; {
            description = "A powerful AI coding agent. Built for the terminal.";
            homepage = "https://github.com/opencode-ai/opencode"; # Replace with your project's homepage
            license = licenses.mit; # Or another appropriate license
            platforms = platforms.linux; # Or platforms.unix, etc.
          };
        };

        devShells.default = pkgs.mkShell {
          name = "opencode";
          packages = with pkgs; [
            # Development tools
            go
            claude-code
            fzf
            
            # Aux tools
            goreleaser
          ];

          shellHook = ''
            export PATH=$PATH:./result/bin

            echo "Welcome to $name"
            export PS1="\[\e[1;33m\][nix($name)]\$\[\e[0m\] "
          '';
        };


    });
}
