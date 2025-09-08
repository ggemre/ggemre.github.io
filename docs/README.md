+++
title = 'README'
date = 2025-09-01T15:28:32+07:00
draft = true
+++

Welcome to my NixOS configuration flake. This is the result of many failures and careful planning. 
My primary goal was creating something extremely simple while avoiding unecessary abstraction and indirection.

# Main Points

* Only depends on one external flake: `nixos/nixpkgs`. This is the only other flake that I trust (besides my own).
* Building my main desktop configuration, `orion`, takes ~12 seconds.
* No Nix "footguns" used:
  - NO overlays!
  - NO importing from derivations!
  - NO `with` usage!
  - NO `rec` usage!
  - NO stylix, home-manager, or any other janky dependencies!
  - NO channels!
  - NO flake-utils!
  - NO impurities or imperative design!

# Design Philosophy

This configuration follows the **KISS** principle. I configure **NixOS only**—no Darwin, no Android, etc.

Nix makes it dangerously easy to bury your configuration under layers of functions, imports, and magic helpers.
Many setups I found were so abstract that even experienced users could lose track of what was happening.
(No knock to them, I definitely have worse garbage on my GitHub and I like to learn from others).
This flake is my answer to that—transparent, minimal, and under control.

# Background

When I first started learning Nix, I made every mistake possible.
Most of the configurations I found online felt wildly over-engineered—so abstract that I sometimes wondered if I was just too dumb to use them.

I went down every rabbit hole trying to understand what others were doing:
- setting up home-manager and stylix
- wiring in flake-utils and flake-parts to split outputs into endless abstractions
- adding overlays for NUR, Rust, chaotic-nyx, and bleeding-edge software
- writing functions to automate trivial tasks like creating hosts, homes, and packages  
- and much more

In the end, I realized most of it was unnecessary complexity. Then, I started really getting into the `zig` programming language, and read this:

> There is no hidden control flow, no hidden memory allocations, no preprocessor, and no macros. If Zig code doesn’t look like it’s jumping away to call a function, then it isn’t.
>
> \- [ziglang.org/learn/overview/](https://ziglang.org/learn/overview/)

Then, it clicked for me. This was what I was missing.

* People were using flake-utils, an external flake in GitHub, to simply call a three line Nix function.
* They left all their styling and theming to be set by stylix, another external flake that took the liberty to theme applications in its own way, (but only for the programs it includes).
* People configured programs with home-manager, which at first sounds nice until you realize that home-manager imports a zillion modules into your config, tripling your eval time,
so that you can have the convenience of configuring programs according to the options that they expose, (and once again only for the programs that it includes).
* But good thing home-manager never breaks stuff, right?
* And instead of simply writing out the control flow of a `nixosConfigurations` output, let flake-parts, snowfall-lib, or some other external flake do it for you so that you can
put files in directories and pray to god that you are following the correct convention.

* [Design](../design)
  * [Writing Modules](../modules)
* [FAQ](../faq)
