---
layout: post
title: GuessMyCheese - Part1
categories:
- picoCTF
- Cryptography
tags:
- ciphers
- affine
image: assets/img/picoCTF.png
date: 2025-07-07 09:23 +0200
---
## Description
Try to decrypt the secret cheese password to prove you're not the imposter!
Connect to the program on our server: `nc verbal-sleep.picoctf.net 60985`

## Connecting
After connecting to the program we are greeted with the following message:

![Greeting from the program](/assets/img/picoCTF_CheeseOne/greeting.png)
*Greetings from the program*

The message contains a *secret cheese* and leaves us with two options
1. guess the cheese
2. encrypt a cheese

I noticed that the secret message is different everytime I connected to the server.

## First Attempt of Decoding
As the message stated that the *secret cheese* is a limited edition I was not expecting *default* cheese.
I then encrypted *gouda* to get an encoded version of it to reference, once I was able to identify the encoding
algorithm.
Assuming I was only dealing with a simple algorithm I tried ROT13 with all possible rotations.
As this was not successful I looked through the options CyberChef offered, but none of them were pointing towards the
solution at first glance.

## Using the hint
The one and only hint that was pointing to a cipher that "incorporates the *affinity* for *linear equations*".
After a quick Google Search, I stumbled across the [*Affine Cipher*](https://en.wikipedia.org/wiki/Affine_cipher).

## Understanding the Cipher
The Affine Cipher Uses a key pair $(a, b)$, where $a$ is a coprime to the number of letters of the alphabet $k$ and
$b$ is between $0$ and $k-1$.
As we are dealing with an English alphabet $k = 26$.
To decode the cipher we also need $a{-1}$ that is matched to $a$

![a inverse](/assets/img/picoCTF_CheeseOne/inverse_a.png)
*Source: https://de.wikipedia.org/wiki/Affine_Chiffre*

To decode, we have to calculate $c = a^{-1} * (y - b) \mod k$, where $c$ is the decoded and $y$ ist the encoded letter.
This has to be done for *every* letter of the encrypted message.

## Decoding the Cipher
Now that I know how to decode the cipher, I was still missing the key to calculate the cleartext.
Luckily there are *only* 312 different keys possible, which makes it *okay* to bruteforce the key.

I tinkered together a [Python-Script](https://github.com/JulesInCyber/Scripts/blob/main/Cryptography/AffineCipher.py)
that was able to encode, decode and even bruteforce the key of an Affine Cipher.

![Brute Forcing](/assets/img/picoCTF_CheeseOne/bruteforce.png)

Using *DHXIN* (which is the encoded *gouda*) as reference, the script uses all possible key combinations $(a, b)$
and decodes the message. 
As soon as I read *GOUDA* in the terminal, I know that I found the valid key and use the same script to decode the
*secret cheese* and retrieve the flag.

![Decoded Message](/assets/img/picoCTF_CheeseOne/decoding.png)
*Decoded Message*
