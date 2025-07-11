---
layout: post
title: BTLO - Phishing Analysis
categories: [BlueTeamLabsOnline, Phishing]
tags: [phishing, analysis, sublime, blue]
image: assets/img/btlo.png
---

## Description
A user has received a phishing mail and forwarded it to the SOC.
Can you investigate the email and attachment to collect useful artifacts?

## Collecting Artifacts

First I opened the email in Thundebird to see what it looked like

![Phishing Mail](/assets/img/BTLO_Phishing/mail.png)
*The Phishing Mail opened in Thunderbird*

This is the mail that was send to the SOC. The original phishing mail is attached.
I downloaded the attachment and opened it in Sublime to gather some artifacts.

When taking a look at (potential) phishing mails you typically want to look for these 
artifacts:

### Email Artifacts

#### Sender
When analyzing a phishing mail it is important to know where the email appears to come from.
This information can be used to identify other mails from that address and link it to other
events.

When looking at an `.eml` file you can look for the `From`-Field. This can look like this:

```
From: "Displayed Name" <sending@email.com>

From: "John Doe" <johndoe123@gmail.com>
```

Note that the displayed name can be altered. So it is more important to look at the sending 
address.

#### Subject Line
This artifact is useful to filter for other emails. It can then be linked to other events.

To find the subject line I used the search function of Sublime:
![Subject Line](/assets/img/BTLO_Phishing/subject.png)

#### Recipient Mail Address
It is important to identify all users who have received the same phishing mail. This can help 
mitigating the risk of a security incident.
Malicious actors tend to enter the recipients in the `BCC` field so it's hard to identify all
recipients.

To find the recipient I searched for `To` in the `.eml`

![Recipient Address](/assets/img/BTLO_Phishing/recipient.png)
*Recipient Address*

#### Sending Server IP
It is important to identify the sending server IP address, as this helps to identify spoofing.
A reverse DNS can reveal even more information about the sender and the used server.

To find the sending server IP I searched for `Originating-IP`:

![Originating IP](assets/img/BTLO_Phishing/originating.png)

Using [reverse DNS](https://whois.domaintools.com) we can gather some useful information such as the location
of the IP and the resolved host

![Resolved Host](/assets/img/BTLO_Phishing/resolved.png)

> This could have been valuable insight if I wanted to check for email spoofing.

#### Date & Time
Knowing the date and time when a email was sent can also help to filter for other emails
sent.

To find the timestamp of the email I searched for `Date`

![Date and Time](/assets/img/BTLO_Phishing/date.png)


### Web Artifacts

#### Full URL
The URL that was included in the email needs to be copied for further analysis.

> When dealing with Hyperlinks make sure not to click the link

As the URL was in plain text, I was able to copy the full URL from Sublime.

To get a safe look at the website I used [URL2PNG](https://www.url2.png.com)

![Screenshot of the Website](/assets/img/BTLO_Phishing/url2png.png)
*Screenshot of the website*

The Screenshot shows what the site would look like, when visiting.
In this case the site has already been taken down.

After that I made sure to defang the URL using `CyberChef` to ensure the link can not be clicked when implementing it
in a later report.
