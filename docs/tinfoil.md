+++
title = 'Tinfoil and Nut Server'
date = 2025-08-22T16:09:55+07:00
draft = true
+++

# Setting up Nut Server on Linux

```yaml
services:
  nut:
    image: shawly/nut
    ports:
      - "9000:9000"
    volumes:
      - "$HOME/proj/switch/games:/nut/titles:rw"
```

1. this is a wip...
2. Open Tinfoil on the Nintendo Switch (hold `R` while opening any game)
3. If you already created the nutfs connection, you can skip steps 4-6
4. Navigate to the file explorer in Tinfoil and press `-` to create a new connection
5. Enter the details of the NUT server connection
  * Protocol: nutfs
  * Host: the local ip address, can be found by running `ip addr`
  * Port: 9000, unless you changed it
  * Username: guest, unless you changed it
  * Password: guest, unless you changed it
  * Path: leave blank or set to `/`
  * Title: leave blank or set to something memorable (like "NUT Server")
6. Save and exit
7. Navigate to the file explorer and open the nutfs connection
8. We are now viewing the files in the NUT server, (physically on this computer), navigate to the `root/titles` directory
9. Select a game with `A` and click the button that says "Install"

