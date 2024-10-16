# Configuring Hyak for the I-FOCUS Project

This folder contains instructions and scripts for configuring one's home
directory and settings on Hyak for use with the I-FOCUS project. Researchers who
do not have access to UW's [Hyak](https://hyak.uw.edu/) compute cluster will be
unable to follow these instructions. The instructions are broken down into
several sections:

1. **Setting up your computer**. New researchers should start here. Before you
   log into Hyak you will need to install some software and configure several
   things on the laptop or desktop you intend to use to access Hyak.
2. **Logging into Hyak**. Instructions on how to log into the Hyak cluster.
3. **Configuring Hyak**. Instructions on setting up your home directory and
   configuring various bits and pieces of the Hyak file system.
4. **Using `hyakvnc`**. Instructions on setting up and using the `hyakvnc` tool.


## Setting up your computer

Using Hyak requires that you have access to a few tools and that you configure
them correctly on whatever laptop or desktop you plan to use to access Hyak. If
you access Hyak using multiple computers, you will need to perform these steps
independently on each of them.

These instructions are intended for a laptop or desktop. While the computer you
are using need not be particularly powerful to use Hyak effectively, it should
not be a mobile device, a tablet, or a simplified laptop like a Chromebook.

### (1) Install Software

**Terminal**. If you are using an Apple device or a PC running Linux, then a
terminal should already be installed. On Mac, you can start the terminal by
clicking on the magnifying glass in your menu-bar (Spotlight Search) and
entering `terminal` then pressing enter. If you are running Windows, then you
will need to install `git-bash`, a terminal program for Windows. Instructions
for installing `git-bash` can be found
[here](https://carpentries.github.io/workshop-template/install_instructions/#shell).
After installing `git-bash` you should be able to search for `git-bash` in the
start-menu.

**TurboVNC**. If you plan to use `hyakvnc` you should also install
[TurboVNC](https://www.turbovnc.org/). This tool can be installed on Mac,
Windows, or Linux.

### (2) Configuring SSH

Hyak can be accessed using [SSH](https://en.wikipedia.org/wiki/Secure_Shell),
which stands for "Secure Shell." The "shell" is the command-line interface for
interacting with a computer or compute cluster, and "secure shell" refers to a
protocol for accessing this interface in a secure manner. We want to tell the
SSH protocol a few things about Hyak and how we connect to it.

The following instructions use Unix shell commands to configure SSH. If you are
unfamiliar with the Unix shell, I suggest reviewing the [Software Carpentry
introduction to the Unix Shell](https://swcarpentry.github.io/shell-novice/)
before continuing.

In the following instructions, anything formatted in bold fixed-width font
(**`like this`**) is intended as a command for you to run in the terminal. Any
part of this that is is delineated by `<` and `>` symbols is intended as a
place-holder or parameter that you will need to fill in. For example, if your UW
NetID were `nben` and you came across the command **`echo <NetID>@uw.edu`**,
then the command that should actually be entered is **`echo nben@uw.edu`**.

1. Open the terminal (see step [(1)](#1-install-software) above for instructions
   on installing and opening the terminal). The terminal provides you with a
   command-line (shell) interface for your computer.
2. The configuration data for SSH lives in a directory called `.ssh` (the `.` at
   the start of the directory name indicates that it is a hidden directory and
   thus won't appear in typical use, for example if you type **`ls`**) in your
   home directory. You should be in your home directory when you open the
   terminal, but you can always type **`cd`** by itself to return to your home
   directory.  
   First, we need to make sure that the directory exists: **`mkdir -p ~/.ssh`**  
   Next, we want to navigate into it: **`cd ~/.ssh`**



## Logging into Hyak

...


## Configuring Hyak

...


## Using `hyakvnc`

...

