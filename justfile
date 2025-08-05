default:
  just --list

[doc('Create a new page (e.g. just new docs/nix/hello.md)')]
new path:
  hugo new {{path}}


  
[doc('Start the nut server')]
[group('server')]
start:
  docker compose up -d

