+++
title = 'Modules'
date = 2025-09-02T21:23:03+07:00
draft = true
+++

[< README](../readme)

I developed my module strategy from what I liked and disliked from configurations I found online.

# Background

Let's look at a simple problem of how to configure a program.

### Module wrappers

I noticed a lot of people made wrappers for configuring programs/systems under their own namespace, e.g.:

```nix
{
  config,
  lib,
  ...
}: let
  cfg = config.MY_NAMESPACE.programs.hyprland;
in {
  options.MY_NAMESPACE.programs.hyprland = {
    enable = mkEnableOption "Whether to enable Hyprland.";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
  };
}
````

This let them use their own module to enable Hyprland, (`MY_NAMESPACE.programs.hyprland.enable = true`), without clashing with the existing NixOS module,
(`programs.hyprland.enable = true`).

I truly see no point to this or why it's so common. By embedding existing NixOS modules inside your own modules, you are hiding away all the existing options
that NixOS creates for you. While I understand the benefit of encapsulation, this makes no sense within a NixOS configuration where you end up with
repetitive code to solve problems that have already been solved for you.

### Depend on external modules

Instead of writing the code necessary to configure Hyprland, I can just depend on something like home-manager.

```nix
{
  inputs,
  ...
}: {
  imports = [ inputs.home-manager.<IDK_HOW_HM_IS_STRUCTURED> ];

  programs.hyprland = {
    enable = true;
    settings = ...
  };
}
```

This strategy is pretty nice if you don't mind importing a zillion modules just to use 1% of them and you are okay with random developers breaking your
config on random updates. I'm not...

### Don't use Nix

This one is down to personal preference, and I used to do this, too. Some people might want to configure a program by simply symlinking their dotfiles.

```nix
{
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.hyprland
  ];

  <SOME_MODULE>.files.".config/hypr/hyprland.conf".source = ./hyprland.conf;
}
```

This is simple and elegant, but I don't prefer it for two reasons.

1. I'm a "100%"er and using Nix to configure everything means I just need a single language in my head when configuring.
(Not that using yaml is hard, but it can be a pain switching from INI to gitINI to KeyValue to hyprConf to toml).
2. Using Nix makes it so unbelievably extensible, see below:

* conditionally changing a setting elsewhere is as simple as updating a value in an attrs:

```nix
# hypridle.nix
programs.hypridle.enable = true;
programs.hyprland.settings.exec-once = [ "${lib.getExe pkgs.hypridle}" ];
```

How would I do this with pure hyprconf files? Appending new lines to the file conditionally? That would get messy and error-prone.

* setting variable data in a config file is trivial:

```nix
settings = {
  color = config.theme.colors.base00;
};
```

How would I do this without Nix? `pkgs.replaceVars`? Sounds like IFD to me...

### Extend NixOS modules

Here is the strategy that I landed on and strikes a perfect balance between simplicity and extensibility:

**If an existing NixOS module has everything I need, use it. If it has part of what I need, extend it.
If no such module exists, create my own in the same vain as existing modules.**

Here is the complete Hyprland module that I use:

```nix
{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.programs.hyprland;
in {
  options.programs.hyprland = {
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Settings to apply to the Hyprland configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    programs.hyprland = {
      xwayland.enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      withUWSM = false;
    };

    systemd.user.targets.hyprland-session = {
      unitConfig = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [
          "graphical-session-pre.target"
        ];
      };
    };

    environment.etc."xdg/hypr/hyprland.conf".text = self.lib.generators.hyprconf cfg.settings;
  };
}
```

Notice how I use the already existing `programs.hyprland` namespace for my module.
This lets me use every existing Hyprland option without having to redefine any, (enable, xwayland, portalPackage, etc).

One thing that was missing, however, was a settings option, so I added in the necessary option and config to change Hyprland settings.

This means I get to use the NixOS Hyprland module, with all its important options, alongside my own defined option.

NixOS doesn't have an ashell module, so I had to create my own entirely from scratch:

```nix
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.ashell;
  tomlFormat = pkgs.formats.toml {};
in {
  options.programs.ashell = {
    enable = lib.mkEnableOption "Whether to enable the ashell status bar.";

    settings = lib.mkOption {
      type = lib.types.nullOr tomlFormat.type;
      default = {};
      description = "Configuration settings for ashell.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ashell
    ];

    homeless.".config/ashell/config.toml" = lib.mkIf (cfg.settings != {}) {
      source = tomlFormat.generate "ashell-config" cfg.settings;
    };
  };
}
```

Notice how its interface is no different from a regular NixOS program module, (`programs.ashell`).
This means when I configure everything, it all blends together as one cohesive set of modules.
