---
title: 
date: 04.03.2025
categories:
  - CaptureTheFlag
  - TryHackMe
tags:
  - Investigation
  - BlueTeam
---

## Briefing
A windows machine has been hacked, its your job to go investigate this windows machine and find clues to what the hacker might have done.

## Establishing a Connection
I will be using my local Kali VM and connect to the machine using `xfreedpr`
```shell
xfreerdp /u:Administrator /p:letmein123! /v:<MACHINE-IP> /dynamic-resolution
```

## Investigating the System
### Windows Version and Year
I used PowerShell to get the needed information of the machine
```Powershell
Get-ComputerInfo -Property OSName, WindowsVersion
```
Turns out, we are dealing with a Windows Server 2016
### Logon Information
We can use PowerShell again to see the last logged on user and get the last time `John` logged in. As we want to know the last logon of the user `Jenny` we will run that command as well
```powershell
# Get the last User that logged in
Get-LocalUser | Sort-Object LastLogon | Select-Object Name, LastLogon -Last 1

# When did John and Jenny last log onto the system
Get-LocalUser -Name John,Jenny | Select-Object Name, LastLogon
```
### Startup Connection
To see the connection that is established after booting up the system, we can check  `msinfo32.exe` for startup programs

![](assets/img/InvestigatingWindows_StartUp.png)

### Admin-Users
We can use
```powershell
Get-LocalGroupMember -Group Administrators
```
to list all users in the Administrators group
### Malicious Task
To identify the malicious scheduled task we open the `Task Scheduler` and have a look at the tasks:

![](assets/img/InvestigatingWindows_ScheduledTasks.png)

We Can See the Task `GameOver` which runs `C:\TMP\mim.exe` Taking a look at the performed Actions we can observe that it seems to write logon passwords to `C:\TMP\o.txt`
However this is not the task that we are looking for. After Checking the Actions for every task we can see `Clean File System` runs another program stored at `C:\TMP`

![](assets/img/InvestigatingWindows_MaliciousTask.png)

### Time of the compromise
Looking at the creation date of the malicious task and the date modified of the `C:\TMP` directory we can safely assume that the compromise took place on March 2nd 2019.

### Assignement of Special Privileges
Doing a quick Google search, we know that we have to look for Event ID 4672. We can filter the Security Events of `eventvwr.exe` 

![](assets/img/InvestigatingWindows_LogonPermissions.png)

This results in quite a few events having the same content. We can look at events that were near the creation time of the scheduled tasks. However this doesn't quite narrow it down. 
Looking at the hint we know that we have to find an that includes 49 seconds in its timestamp.
This gets us an Event at **03/02/2019 4:04:49 PM**
### Attacker's Tool
To get the tool that was used, we can take a look at `C:\TMP`. As we already know the task `GameOver` runs `C:\TMP\mim.exe`. We can also see a `mim-out.txt` in the directory.
Looking into it, we can identify `Mimikatz` as the tool that was used.
### IP Address of the attacker
As the last question points us towards *DNS Poisoning* we will have a look at `C:\Windows\System32\drivers\etc\hosts`

![](assets/img/InvestigatingWindows_Hosts.png)

The entry for `google.com` stands out and after doing a `nslookup` on my local machine we can see that the IP address does not match

![](assets/img/InvestigatingWindows_NSLOOKUP.png)

Thus we can confirm DNS poisoning targeting `google.com`
### Uploaded Shell
To find the uploaded shell we check the default directory for Windows Web Servers using PowerShell
```powershell
Get-ChildItem C:\inetpub\wwwroot
```

![](assets/img/InvestigatingWindow_serverlog.png)

### Last Opened Port
Looking at the configuration of the firewall configuration we can see there was a rule to allow any outside connection using port 1337.

![](assets/img/InvestigatingWindow_Firewall.png)

## Securing the System
To clean up the system and secure it we would have to take the following steps:

- Delete the scheduled tasks `GameOver` and `Clean File System` as they were classified as malicious
- Remove the startup script we found in `msinfo32.exe`
- Remove the users *Jenny* and *Guest* from the Administrator Group.
    - Disable the Account for Jenny as long as we cannot confirm it is a legit user
- Change passwords of all users as we saw that logon passwords were written to a file
- Remove the Firewall rule that allows connections using port 1337
- Create Firewall rules that block port 1348 and connections to the attackers IP address
- Remove the shell uploaded to `C:\inetpub\wwwroot`
- Restore the `hosts` file
- Clear `C:\TMP`
    - you might want to move the files to a sandbox for further investigation