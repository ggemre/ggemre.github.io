{
  description = "Website builder with typst, pandoc, and python3 http server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
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

      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          build = {
            type = "app";
            program = "${self.packages.${system}.ssg}/bin/ssg";
          };
          serve = {
            type = "app";
            program = "${pkgs.python3}/bin/python3 -m http.server 8000 --directory public";
          };
        });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.bash
              pkgs.pandoc
              pkgs.typst
              pkgs.python3
            ];
          };
        });
    };
}
