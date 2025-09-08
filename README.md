# Personal Website

This is a static site that uses `html`, `typst`, and `markdown` as sources. The site is automatically generated with Nix, (in GitHub actions or can be run locally).

### Note to self

Building the site (i.e. I have a bunch of markdown, typst, and html in src/ and want a full website in result/):

Note that Nix will only see files that have been added to git.

```sh
nix build
```

Serve the site locally (to view it before deploying to GitHub pages):

```sh
nix run .#serve
```

Need a dev shell with helpful tools?

```sh
nix develop
```

Format all `nix`, `html`, `markdown`, and `typst` files:

```sh
nix fmt
```
