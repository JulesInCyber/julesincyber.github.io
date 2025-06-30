---
layout: post
title: picoCTF - Fix Me 2
categories: [picoCTF, Basic Skills]
tags: [python, scripting]
image: assets/img/picoCTF.png
---
## Description
Fix the syntax error in this Python script to
print the flag.

## Fixing the script
When you run a program using `python3 script.py` you usually
get a message, if you run into an error.
With that in mind, I ran the program without prior checking.
This returned a syntax error.

![Python Syntax Error](/assets/img/picoCTF_FixMe/python_syntax.png)
*Running the program returns an error*

> Using only one '=' sets a variable (e.g. x = 1) for further use.
> When comparing values within loops or if statements you need '=='.
{: .prompt-tip}

Now that I know where to look, I opened the script using `nano`
and fixed the syntax error.

As I didn't spot any other issues with the code, I saved the changes and ran the script again.
This time i ran without any errors and returned the flag:

![Flag](/assets/img/picoCTF_FixMe/flag.png)

