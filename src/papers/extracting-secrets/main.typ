#import "template.typ": *

#show: project.with(
  title: "Extracting Secrets",
  authors: (
    "Gage Moore",
  ),
  date: "November 7, 2023",
)

= Introduction
For this lab, we start with a binary executable, `secret_treasure`, and an encrypted secret file, `treasures.enc`. When running the program, like so...

```sh
./secret_treasure treasures.enc
```

...it will prompt the user for a password, and if this password is not correct the message `Who are you trying to fool?` will be printed and the program will quit.

#image("Screen Shot 2023-11-07 at 2.10.44 PM.png")

= Procedure

== Investigation
In order to figure out the contents of `treasures.enc`, we will need to somehow bypass the password protection of `secret_treasure`. First, I will create a hexdump of the disassembled `secret_treasure` executable.

```sh
objdump -M intel -d secret_treasure > dump.txt
```

This produces the file `dump.txt`, which can be examined with `vim`. Within the code, one function, `checkKey`, sticks out to me as the portion of the program that validates the user input before allowing access to the "treasures".

#image("Screen Shot 2023-11-07 at 2.16.31 PM.png")

The bottom of the `checkKey` assembly stands out to me as particularly interesting. It gets a value from `%rbp` and compares that value with `$0x0`. If the values do not match, we jump to address `14b5`. If the values do match, we continue down the flow, eventually jumping to `<__stack_chk_fail@plt>`.

#image("Screen Shot 2023-11-07 at 2.20.05 PM.png")

In order to better understand what is being moved to `%eax` and what the immediate `$0x0` means, it is time to debug the executable with `gdb`.

```sh
gdb secret_treasure
```

Once in the `gdb` prompt, I want to set a breakpoint at the `checkKey` function that I found. Next, I run the executable with the encrypted file and wait for it to hit the breakpoint.

#image("Screen Shot 2023-11-07 at 2.25.41 PM.png")

Entering `info locals` prints the local variables at this breakpoint. The variable names are descriptive enough to tell me how the authentication process works. It appears that there is a boolean, `isValid`, and a boolean, `isEqual`. I can assume that the function checks that my input was valid, then checks if it is equal to the correct key before deciding if I jump ahead or not.

There are also the local variables of `keyHash` and `expectedKeyHash`. I can assume that my input is hashed, and compared against the hash of the correct key. This level of security prevents me from extracting the secret key from the executable, unfortunately.

#image("Screen Shot 2023-11-07 at 2.27.26 PM.png")

By examining the assembly code from `layout asm`, I am able to step through the program to the precise point of interest that I identified in `dump.txt`. At this point, the program is comparing the immediate `$0x0` with the contents at `-0x34(%rbp)`. By finding what is held in the address `rbp` via `i r rbp` and printing what is located at the stack base pointer plus the offset of `-0x34`, it interestingly turns out to be equal to 1.

#image("Screen Shot 2023-11-07 at 2.35.12 PM.png")

Because the value is 1, the comparison will turn out to be not equal, and the program will skip the following `jne` command, eventually hitting the `<__stack_chk_fail@plt>` part of the program, which I can only assume is what prints out the failed message. In order to bypass the check while running in `gdb`, I will change the booleans of `isValid` and `isEqual` to 1.

#image("Screen Shot 2023-11-07 at 3.56.31 PM.png")

After doing this, I am able to step through the program further. Interestingly, it switches back to the `main` function, and I found another local variable called `isValidKey`. It was already set to 1, and I was able to get a secret printed after stepping down further.

#image("Screen Shot 2023-11-07 at 3.58.18 PM.png")

Now, I want to modify the executable itself so that it prints a secret message every time it is run, regardless of what the user entered into it.

== Manipulation
My plan to bypass this password check no matter what the user enters was to replace the comparison with something that will always evaluate to being equal. I decided to replace the `cmp $0x0,-0x34(%rbp)` with something like `test eax,eax`. To do this, I opened up `dump.txt` and tried to find anywhere that a register is compared with itself, since I knew sometimes assembly does this to set flags based on a single register.

I found an example of this in use at address `138a`. The apparent hexcode for this instruction is `48 85 c0`.

#image("Screen Shot 2023-11-07 at 3.09.07 PM.png")

While examining the line I wanted to replace, I noticed that the instruction takes up 4 bytes instead of 3.

#image("Screen Shot 2023-11-07 at 2.45.35 PM.png")

With all of this in mind, my gameplan was to set the 4 byte instruction at address `19b1`, (the comparison with the key flag), with the bytes `90 48 85 c0`, or in other words a  `noop` instruction followed by a `test rax,rax` instruction. Since this would always evaluate to being equal no matter what the user entered, I also needed to change the following `jne` instruction to a `je` instruction so that it would always take the correct key branch no matter what the key is. This is done by simply changing the opcode from `75` to `74`. 

With this in mind, I opened up vim on the executable itself, and made my insertions.

#image("Screen Shot 2023-11-07 at 3.11.46 PM.png")

I then saved the new executable and ran it like I did before. This time, however, when entering whatever I pleased for the key, secret messages would get printed out.

#image("Screen Shot 2023-11-07 at 3.13.14 PM.png")

== Getting every treasure
Now that the key check has been bypassed, I want to print every single message from `treasure.enc`. Within `gdb`, I investigated how to do this by continuing past the key check, checking the local variables at each step.

#image("Screen Shot 2023-11-07 at 3.37.33 PM.png")

By examining the local variables, it appears that there is a `treasureIndex` value that is set to a random value given a `seed`. I am assuming that the index determinstically corresponds to a message in `treasures.enc`. 

Since I can manually change local variables while running a program in `gdb`, the easiest way I can think of getting every message in `treasures.enc` is to start from an index of 0 and incrementing it, printing out the message for each index, until I get some sort of "out of bounds" error.

#image("Screen Shot 2023-11-07 at 3.40.15 PM.png", width: 85%)

After running through for every index, these are the messages that I collected:

\ \
```txt
Win NT error 001: Error recording error codes. All further errors not displayed.

"Do not meddle in the affairs of wizards, for you are crunchy and good with ketchup."

Rincewind had generally been considered by his tutors to be a natural wizard
in the same way that fish are natural mountaineers.  He probably would have
been thrown out of Unseen University anyway--he couldn't remember spells and
smoking made him feel ill.
                -- Terry Pratchett, "The Light Fantastic"


                 ___          ______           Frobtech, Inc.
                /__/\     ___/_____/\
                \  \ \   /         /\\
                 \  \ \_/__       /  \         "If you've got the job,
                 _\  \ \  /\_____/___ \         we've got the frob."
                // \__\/ /  \       /\ \
        _______//_______/    \     / _\/______
       /      / \       \    /    / /        /\
    __/      /   \       \  /    / /        / _\__
   / /      /     \_______\/    / /        / /   /\
  /_/______/___________________/ /________/ /___/  \
  \ \      \    ___________    \ \        \ \   \  /
   \_\      \  /          /\    \ \        \ \___\/
      \      \/          /  \    \ \        \  /
       \_____/          /    \    \ \________\/
            /__________/      \    \  /
            \   _____  \      /_____\/
             \ /    /\  \    / \  \ \
              /____/  \  \  /   \  \ \
              \    \  /___\/     \  \ \
               \____\/            \__\/


Win98 error 001: Unexpected condition: booted without crashing.

Win98 error 002: Insufficient diskspace. You need at least 300 GB free memory.

Win98 error 003: Illegal ASM instruction. If your modem worked properly, the FBI would have been called.

Win98 error 004: Virus activated from DOS Prompt - but the virus requires Windows. Your system will be rebooted for the Virus to take effect. [ OK ]

Win98 error 005: Mouse not found. Click left mouse button on ok to continue.

Win98 error 006: Keyboard not found. Press F1 to continue.

(1)     Office employees will daily sweep the floors, dust the
        furniture, shelves, and showcases.
(2)     Each day fill lamps, clean chimneys, and trim wicks.
        Wash the windows once a week.
(3)     Each clerk will bring a bucket of water and a scuttle of
        coal for the day's business.
(4)     Make your pens carefully.  You may whittle nibs to your
        individual taste.
(5)     This office will open at 7 a.m. and close at 8 p.m. except
        on the Sabbath, on which day we will remain closed.  Each
        employee is expected to spend the Sabbath by attending
        church and contributing liberally to the cause of the Lord.
                -- "Office Worker's Guide", New England Carriage
                    Works, 1872
```

\ \ \
After I hit a `treasureIndex` of 11, everything after this index printed the first message every time, which was not what I expected to happen but it indicated to me that I was done.
