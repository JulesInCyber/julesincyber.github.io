---
layout: post
title: SUID Misconfiguration
categories: [Know-How]
tags: [linux, security]
---

## What is SUID?

The **Set User ID** is a special permission bit used in UNIX systems that applies to executable files.
When this bit is set, the program is executed with the privileges of the file owner

## Issues caused

1. Privilege Escalation
If a vulnerable or poorly programmed SUID binary exists, an attacker gan gain `root` privileges.
2. Shell Escapes
If a SUID program calls shell commands, a user might be able to inject their own commands.

## How to find SUID files

On a Linux system the following command can be used to find SUID files that are owned by `root`:

```shell
find / -user root -perm /4000 2>/dev/null
```

## Mitigations

- Regularly check for SUID files
- Remove unnecassary SUID bits

```shell
chmod u-s /path/to/file
```

- Replace with `sudo` where appropriate
