# Personal Website

This is a static site that uses `html`, `typst`, and `md` as sources. The site is automatically generated with Nix, (in GitHub actions or can be run locally).

### Note to self

Building the site (i.e. I have a bunch of markdown, typst, and html in src/ and want a full website in result/):

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

Format all files in src/

```sh
nix fmt
```
