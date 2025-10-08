+++
title = 'Faq'
date = 2025-09-02T21:15:48+07:00
draft = true
+++

[< README](../readme)

Some questions that may pop into some people's heads regarding my setup...

### Why don't you use overlays?

I don’t use overlays because I don’t need them. Overlays are useful when you need to modify a package in nixpkgs and have that modification propagate to all other packages that depend on it.

In my case, I only have a few custom or patched programs that I want to expose through my flake.
For that, the packages output is a simpler choice. It avoids rewriting the entire nixpkgs set for each change, which can significantly slow down builds.

### What is IFD and why do you have it disabled?

Import From Derivation (IFD) allows you to generate Nix expressions during evaluation. 

* It can make evaluation non-deterministic, since results may depend on build-time artifacts.
* It increases build and evaluation times, as Nix must build intermediate derivations before it can fully resolve the configuration.
* Debugging becomes harder because the configuration graph isn’t fully visible until after certain steps are executed.

### Why don't you use the `with` keyword?

It obscures where values come from, and I prefer for all declarations to be explicit, (check out zig's philosophy).

### Also, why don't you use the `rec` keyword?

I just never need to and I've heard it can lead to hard-to-debug problems. Someone on NixOS discourse puts:

> * It’s possible to introduce a hard to debug error infinite recursion when shadowing a variable, the simplest example being rec { b = b; }.
> * combining with overriding logic such as overrideAttrs function in nixpkgs has a suprising behavour of not overriding every reference.
>
> https://discourse.nixos.org/t/avoid-rec-expresions-in-nixpkgs/8293/4

### Why don't you use flake-utils?

If you are using a ton of utility functions from flake-utils, like all the things they have to filter and flatten attrs, then ignore what I'm going to say.

Sometimes, dictionaries publish their wordsets with a couple of fake definitions scattered throughout to act as a **TRACER** to find anyone stupid enough to copy them.
This is the true reason why flake-utils was created. Everytime you come across a flake template for a programming language, a flake for a NixOS system, or a flake for building a package,
and they used flake-utils to export something for `eachDefaultSystem`, it means one of two things:

1. This person copied their code from someone else who used flake-utils, meaning they don't understand their own code well enough for you to use it as a reference.
2. They deadass used flake-utils to replace what would otherwise be a microscopic Nix lambda function, meaning once again, do not use them as a reference, (or import their stuff).

People who use flake-utils `eachDefaultSystem` in their NixOS flake that only configures x86_64-linux systems make it just that much more egregious.
It's cool that you have your own overlays and packages, but have they all been tested on every default system? Really? Your two x86_64-linux laptops have at some point
consumed an aarch64-darwin package? That's really cool.

### Stylix is so convenient, why don't you use it?

Stylix is great for automatic system-wide theming, but it only supports a limited set of applications and enforces its own opinionated styling choices.
I was able to replace stylix with an attrs that I can then use to theme applications EXACTLY how I want. Stylix sucks away a bit of my agency.

### Why don't you use home-manager? Everyone else uses it!

My biggest gripe with home-manager is just the insanely inflated eval times that it brings it due to a large number of modules. Some other issues:

* It only supports applications that have corresponding modules. If you have something niche, you're going to be managing it manually, anyway.
* It can obscure where certain configuration changes originate.
* It breaks a little too often for me to enjoy its convenience.

My solution: use the existing NixOS modules, and extend them whenever I need added configurability. I have a simple little module to write home files, too.

P.S. some people shirk home-manager and go straight to hjem-rum to enjoy the faster eval times.
But...hjem-rum automatically imports every module too, it just has less of them. So as it grows, it will have the same problem as home-manager, just with less choices.
What magic am I missing that motivates someone to do that? Just switch to pure hjem, or if you're like me, write your own home file module!

### Why don't you use impermanence?

Good question... I used to. I set up the impermanence module with zfs snapshots and enjoyed it, but it felt a little shaky.
What I mean is...it's not something I can just set up and be done with. Most changes to my configuration would necessitate persisting some new file or directory.
Forgetting to do that isn't a huge deal on a declarative system, but it still felt annoying.

Since I always had a disk utilization monitor in my bar, I can honestly say that with and without impermanence, the space gains were not worth the hassle of setting it up
and then continually maintaining it.

Honestly, no hate to anyone that uses it. I love the idea, and the flake is simple enough that I could make it into my own internal module, but like I said, I just don't want to.
Might change in the future...

### Why don't you use disko?

I do...to partition and mount my disks. It's super handy! But after I run disko, I can just run `nixos-generate-config --show-hardware-config --root /mnt > hardware.nix`.

This gives me a clean, static filesystem declaration without relying on an external module filled with a million options I’ll never use.
That keeps things straightforward and avoids unnecessary abstraction.

### Why don't you use channels?

I don't need to with flakes. Channels feel like an older direction of the Nix ecosystem before things started to mature, sort of like `nix-env`. That's pretty much all I can say about them, I don't know much about channels.

### Why don't you use the NUR? Or Chaotic-nyx?

At first, it feels fun to plug in a massive overlay to your configuration and have instant access to tons of bleeding-edge software and custom programs.
In my flake, however, if I ever desire such a piece of software, I just package it myself.

Do I ever use public overlays online as a reference to package things? Absolutely. But a massive overlay just to consume one or two packages is so overkill, (and hurts eval time).

### Why don't you use \<insert new flake that everyone is using\>?

New tools and flakes appear in the Nix ecosystem all the time, and it’s easy to feel like you need to adopt each one to stay current.
But for my configuration, I value control, transparency, and performance over following trends.

If I can achieve something quickly and cleanly on my own,
I prefer to avoid adding another external dependency—especially if it adds complexity or obscures what my system is actually doing.
If something new is worth integrating into my workflow, then I will absolutely give it a shot!

