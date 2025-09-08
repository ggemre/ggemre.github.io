{
  description = "Website builder with typst, pandoc, and python3 http server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable?shallow=1";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix);
    in
    {
      packages = eachSystem (pkgs: {
        ssg = pkgs.writeShellApplication {
          name = "ssg";

          runtimeInputs = [
            pkgs.bash
            pkgs.pandoc
            pkgs.typst
          ];

          text = builtins.readFile ./scripts/build.sh;
        };
      });

      apps = eachSystem (pkgs: {
        build = {
          type = "app";
          program = "${self.packages.${pkgs.system}.ssg}/bin/ssg";
        };
        serve = {
          type = "app";
          program = "${pkgs.python3}/bin/python3 -m http.server 8000 --directory public";
        };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.bash
            pkgs.pandoc
            pkgs.typst
            pkgs.python3
          ];
        };
      });

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    };
}
