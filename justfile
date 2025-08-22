default:
  just --list

[doc('Create a new page (e.g. just new docs/nix/hello.md)')]
new path:
  hugo new {{path}}


  
[doc('Start development server')]
[group('server')]
start:
  hugo serve
