---
layout: post
title: BTLO - Spectrum
categories:
- BlueTeamLabsOnline
- Forensics
tags:
- steganography
- spectography
image: assets/img/btlo.png
---
## Scenario
Scotland yard have intercepted information about one of the biggest drug deals to go down in the city of London. Someone we believe is linked to the deal was arrested. The only item they had in their possession was a USB thumb drive. Unfortunately, one of our junior analysts was unable to find anything of interest. Before we let this suspect go, we would like one of our DF experts to see if they can find anything about the deal before it goes down. Can you find out where and when the deal is expected to go down? 

## Obtaining the files
I started by downloading and extracting the file to a dedicated directory for the investigation.
The file that was extracted is a `image.dd` file.

## Analysis
As I was confronted with an image file, I started check what kind of image I am dealing with.

```shell
┌──(julian㉿kali-box)-[~/CaptureFlags/BTLO/Spectrum]
└─$ file image.dd                                             
image.dd: DOS/MBR boot sector, code offset 0x3c+2, OEM-ID "mkfs.fat", sectors/cluster 4, reserved sectors 4, root entries 512, Media descriptor 0xf8, sectors/FAT 100, sectors/track 62, heads 58, hidden sectors 2048, sectors 102362 (volumes > 32 MB), reserved 0x1, serial number 0x2b873cba, unlabeled, FAT (16 bit)
```

The scenario already states that our evidence is a USB drive, which are usually no *Full images*.
As the file system starts at sector 2048 it is confirmed that we are dealing with a partition image. 
Given this I startet up autopsy using `sudo autopsy` and opened the GUI in the browser. After creating a new case and importing the image as partition I was able to see the files
present on the USB-image.

![File Analysis of the image](/assets/img/BTLO_Spectrum/Autopsy.png)
*Files present on the image*

I started by by using `scalpel` to get the images.
As the images provided no visual evidence I ran `exiftool` on all images and found an interesting looking entry on the last image

![Steghide Password](/assets/img/BTLO_Spectrum/SteghidePassword.png)
*The metadata reveals a steghide password*

I took a closer look at all the images and noticed that image number 5 was slightly bigger. I expected to find something hidden here.
After an initial `stegide extract -sf 00000004.jpg` was not successful I tried different alterations for the password using `stegseek` and a password list.
After multiple attempts using all kinds of alterations on all carfved images I felt I was running into a dead end -- almost forgetting there was something else that needed further analysis

To extract the zip file i used `binwalk -e image.dd`. This gave me the zip file I tried to unzip using `7z`.

![7Zip Extraction](/assets/img/BTLO_Spectrum/7zip.png)
*Trying to unzip the file*

As the archive was password protected I tried the retreived password from the metadata -- assuming the steghide hint was misleading -- 
and it failed.

I then used `fcrackzip` in combination with `rockyou.txt` and was able to find a possible password.

![fcrackzip](/assets/img/BTLO_Spectrum/fcrack.png)

I was able to extract the files from the archive using the found password and got the `wav` files.
I then used a media player and skipped through all the audio files, to see if this would lead anywhere. 

The `location.wav` is an audio file that sounded like  morse code. To transcribe the code, I used a [spectrum visualizer](https://github.com/JulesInCyber/CTF-Related/blob/main/Tools/Blue/spectral.py). This made it easier to read the morse code and insert it into cyberchef.

![Hidden Morse](/assets/img/BTLO_Spectrum/location.png)
*The morse message visualized*


```
-. .. -.-. .
- .-. -.-- --..--
-. --- - .... .. -. --.
- ---
.... . .- .-. 
.... . .-. . -.-.--
```

which translates to: *NICE TRY, NOTHING TO HEAR HERE!*

After that I listened to all files again, thinking I must have missed something. 
I listened to the `white.wav` first and was able to hear some kind of sound artifact. It was
worth trying to visualize that audio file as well.

![Spectograph of white.wav](/assets/img/BTLO_Spectrum/white.png)
*Spectograph of white.wav*

This looked a lot like coordinates. Which could be used to find the Location of the secret meeting.
With only the time left to find, I came back to my notes and noticed I still had a stegseek password that was of no use so far.

Using `steghide extract -sf white.wav` and the previously obtained password I was able to extract a file called `stardate.txt`.
This file cointained a string that looked encoded.
I used [this site](https://dcode.fr) to identify the encoding algorithm.
It was likely Base58, so I was able to decode the message using CyberChef. 
As the message ended in `emit`, which is *time* but backwards, I figured out how to interpret the message and was able to reveal the time of the meeting.
