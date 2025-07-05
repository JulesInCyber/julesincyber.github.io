---
layout: post
title: BTLO - Squidgame
categories: [BlueTeamLabsOnline, Forensics]
tags: [steghide, osint]
image: assets/img/btlo.png
---

- Download & unzip using `7z x`
- Google Research for phone: trailer for s1: https://www.youtube.com/watch?v=oqxAJKy0ii4 --> 010-034: edited, due to original number was from a real person
	- original number: https://www.youtube.com/watch?v=fFun6DjNT3Q 8650-4006

## Scenario
Will you survive the Squid Games? 

## OSINT
To get the phone number on the invitation card I had to use my OSINT skills.
My first intention was to check the trailer. The first few seconds showed the card from both sides including *a* phone number. After this phone number turned out to be 
not correct, I checked IMDB for trivia and had to learn that the number was edited as the *original* number belonged to a real person.
I refined my Google search and looked for the original number and found it in a [Reddit-Post](https://www.reddit.com/r/squidgame/comments/qfbfhp/meaning_of_010034_number_on_business_card/).

## Extracting the hidden file
As the next question was explicitly asking for an extracted file, I used `stegseek`
