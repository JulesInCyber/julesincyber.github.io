---
layout: post
title: Ph4nt0m 1ntrud3r
categories: [picoCTF, Forensics]
tags: [wireshark, network, pcap, decoding, cyberchef]
image: assets/img/picoCFT.png
---

> This challenge was part of *picoCTF 2025*

## Description
A digital ghost has breached my defenses, and my sensitive data has been stolen!
Your mission is to uncover how this phantom intruder inflitrated my system and retrieve the hidden flag.

To solve this challenge, you'll need to analyze the provided PCAP and track down the attack method.
The attacker has clearly concealed his moves in well timely manner. 
Dive into the network traffic, apply the right filters and show off your forensic powers and unmask 
the digital intruder.

## Resources
The PCAP file can be downloaded here: [PCAP File](https://challenge-files.picoctf.net/c_verbal_sleep/586d0206891cc683bae1160ad6b0e05d7e10e7b2df122c0441ab06581038dd32/myNetworkTraffic.pcap)

## Analysis
The first thing that can be observed after importing the PCAP file into Wireshark is that the packets are not in order.
We can fix that by simply sorting the packets by time rather than the packet number.

After obtaining the correct order, we will use a filter to show only packets that were captured beginning with the relative time of 0

```shell
frame.time_relative >= 0 && tcp.len == 12
```

This leaves us with only a few packets, that all contain a Bas64-Encoded payload. 
To extract the payload, we will select the TCP Payload and press `CTRL + Shift + O`

We can then copy the strings to Cyberchef and use the *From Base64* operation, to reveal the flag.

> Using CyberChef I did not receive the finel closing tag for the flag
> As I was at the end of my filtered packets I manually entered it, as this was probably the end of the important data stream
