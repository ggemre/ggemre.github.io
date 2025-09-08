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
        default = pkgs.stdenv.mkDerivation {
          pname = "www";
          version = "1.0";
          src = ./.;

          nativeBuildInputs = [
            pkgs.bash
            pkgs.pandoc
            pkgs.typst
          ];

          buildPhase = ''
            bash ./scripts/build.sh
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };
      });

      apps = eachSystem (pkgs: {
        serve =
          let
            site = self.packages.${pkgs.system}.default;
            serveScript = pkgs.writeShellScriptBin "serve-site" ''
              exec ${pkgs.python3}/bin/python3 -m http.server 8000 --directory ${site}
            '';
          in
          {
            type = "app";
            program = "${serveScript}/bin/serve-site";
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
