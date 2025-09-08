#import "template.typ": *

#show: project.with(
  title: "PGP and S/MIME",
  authors: (
    "Gage Moore",
  ),
  date: "November 30, 2023",
)

= Email Exploration

I exchanged emails with *REDACTED*. We learned a great deal about the importance of PGP and S/MIME and had fun whilst learning.

=== Part 1 - S/MIME

S/Mime is a widely used cryptographic protocol designed for digitally signing and encrypting email messages. It uses asymmetric cryptography to protect users' emails from unwanted third-party access and involves digital signatures in order to verify the sender's identity.

The first step is to get an S/MIME certificate. This was the hardest part of the lab for me and generated a lot of frusteration. I was able to download a certificate from the Italian company _Actalis_. The certificate download page was frighteningly sketchy and resulted in 500-level errors until it correctly provided an S/MIME certificate after about 20 minutes of trying.

With an S/MIME certificate in hand, (and Vijay having accomplished the same thing), we then exchanged certificates so that both could be added to our email client, Thunderbird. We exchanged certificates via email and PGP, which is described in the next section. By adding the certificates for our respective emails, Thunderbird would be equipped to sign and encrypt emails sent between both me and Vijay. A screenshot of these certificates being added in Thunderbird is shown below:

#image("smime_certs.png", width: 80%)

Once we had these S/MIME certificates properly imported within our email clients, we then exchanged emails. I was able to send an email, (both encrypted and digitally signed via S/MIME), as shown in the screenshot below.

#image("send_smime.png", width: 80%)

Vijay did the same thing, and upon receiving his email I was pleased to find that it was verified, (on account of being digitally signed), and encrypted, (which Thunderbird automatically decrypted for me). A screenshot of the received email is shown below:

#image("received_smime.png", width: 80%)

\ \
=== S/MIME SUS Score

Each question is given a score of 1-5.

*I think that I would like to use this system frequently:* 2 \
*I found the system unnecessarily complex:* 3 \
*I thought the system was easy to use:* 2 \
*I think that I would need the support of a technical person to be able to use this system:* 2 \
*I found the various functions in this system were well integrated:* 2 \
*I thought there was too much inconsistency in this system:* 1 \
* I would imagine that most people would learn to use this system very quickly:* 1
*I found the system very cumbersome to use:* 3
*I felt very confident using the system:* 2
*I needed to learn a lot of things before I could get going with this system:* 5

SUS Score: 37.5.


=== Part 2 - PGP

PGP stands for "Pretty Good Privacy". It is an encryption program that can be used for encrypted and decrypting data. For the purpose of this lab, Vijay and I sent and received emails protected by end-to-end encryption using PGP. This was accomplished with the extension _Mailvelope_.

Within the extension, I was able to create a key pair that would be used for encryption. Like S/MIME, sending PGP-protected emails involves asymmetric encryption via a key pair. My key pair is included below, alongside Vijay's public key.

#image("pgp_certs.png", width: 80%)

With my key pair generated, I successfully sent an encrypted email to Vijay, and received one from him as well.

#image("pgp_semd.png", width: 80%)

=== PGP SUS Score

Each question is given a score of 1-5.

*I think that I would like to use this system frequently:* 4 \
*I found the system unnecessarily complex:* 2 \
*I thought the system was easy to use:* 5 \
*I think that I would need the support of a technical person to be able to use this system:* 1 \
*I found the various functions in this system were well integrated:* 2 \
*I thought there was too much inconsistency in this system:* 1 \
* I would imagine that most people would learn to use this system very quickly:* 2
*I found the system very cumbersome to use:* 1
*I felt very confident using the system:* 4
*I needed to learn a lot of things before I could get going with this system:* 1

SUS Score: 77.5.

== Quick Conculsion

Going forward, I will continue using encryption standards for my email, like the methods described above, because I feel that they improve my privacy while using email and are worth it in the daily activity that I am involved in with email.

