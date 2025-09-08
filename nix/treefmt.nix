{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    prettier.enable = true;
    mdformat.enable = true;
  };
  settings.excludes = [
    "*.lock"
  ];
}
