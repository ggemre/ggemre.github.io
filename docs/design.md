+++
title = 'Design'
date = 2025-09-02T21:21:54+07:00
draft = true
+++

[< README](../readme)

# The actual design of my flake

I know I mentioned a lot of what my flake *isn't*, so I'll lay out what it *is*.

### Only depending on `nixos/nixpkgs`

To me, nixpkgs is the primary reference for writing clean, modular Nix code. When I need guidance on directory naming or module structure, I look there first.

In the past, using multiple external flakes often led to update headaches—each input would change, and I’d spend time tracking down breakages across them.
By depending only on nixpkgs, I avoid compatibility issues between unrelated components and keep my setup lean.

I also import nixpkgs with `shallow=1`. I’m not sure how much of a performance benefit this provides (and I know Lix doesn’t support it),
but it at least feels like one more step toward keeping things minimal. If you know more about the impact, I’d appreciate insights.

Also, take a look at the grace of my `flake.nix` file, in its 16 lines of readability:

```nix
{
  description = "Optimized Nix flake for all my NixOS systems.";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable?shallow=1";
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    nixosModules = import ./modules;
    nixosConfigurations = import ./hosts inputs;
    formatter = import ./nix/formatter inputs;
    devShells = import ./nix/shell inputs;
    packages = import ./pkgs inputs;
    lib = import ./lib inputs;
  };
}
```

### Flake outputs

Here are the outputs of my flake:

```
ggemre/nixos-config
├───devShells
│   └───x86_64-linux
│       └───default: development environment 'Flake-dev-shell'
├───formatter
│   └───x86_64-linux: package 'alejandra-4.0.0'
├───lib: helpful utility functions
├───nixosConfigurations
│   └───orion: Main laptop
├───nixosModules
│   ├───common: Settings that all NixOS hosts import
│   ├───config: Configuration settings for programs
│   ├───homeless: Simple and idempotent home management
│   ├───profiles: Settings for specific kinds of systems
│   ├───programs: Options for programs to be configured
│   └───theme: Set consistent themes for use elsewhere
└───packages
    └───x86_64-linux
        ├───alejandra-patched: package 'alejandra-4.0.0'
        └───hello: package 'hello-1.0'
  
```


