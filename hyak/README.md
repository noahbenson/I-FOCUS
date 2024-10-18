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
3. In order to tell SSH about Hyak, we need to edit the `config` file that lives
   in this `.ssh` directory. If you are familiar with a Unix text editor like
   vim or emacs, feel free to use it for this step; if not, we will use `nano`,
   which is a very simple built-in text editor. (See [this
   page](https://tech.wayne.edu/kb/high-performance-computing/hpc-tutorials/500111)
   for introductory instructions on how to use nano.  
   To use `nano` to open the `config` file: **`nano config`**  
   This should open nano, which will redraw the text in your terminal. If the
   `config` file already contains text, that's okay--just go to the bottom of
   the file using the down key and add the following text (if the file appears
   empty, just add this at the top):  
   ```
   Host hyak
     HostName klone.hyak.uw.edu
     User <NetID>
     LocalForward 7777 /mmfs1/home/<NetID>/.hyak-jupyter/tunnels/default/login.sock
   ```  
   Note that the two occurrences of `<NetID>` above need to be replaced with
   your NetID.  
   Once you have entered the text above, you can save the file by pressing
   control+O (O for "write output") and pressing enter when it prompts you
   to edit the filename then pressing control+X (X for "exit"). There is a
   key of these keyboard commands at the bottom of the nano screen; the `^`
   symbol stands for control, so `^X` means control+X.


## (3) Logging into Hyak

Once you have followed the steps in [(2)](#2-configuring-ssh), you should be
able to log into Hyak using the command **`ssh hyak`**. The first time you enter
this command, you may be given a prompt about the authenticity of the host; it
typically ends with `Are you sure you want to continue connecting
(yes/no/[fingerprint])?`.  It is typically safe to answer `yes` to this
question, and you should only be prompted the first time you connect on each
computer. (If you happen to be on a network that you know is unsecure, then you
should verify that the second line of this message says `ED25519 key fingerprint
is SHA256:Ww2boukhve4pYouM6N/I5Ri1dsVjd383DthYcmFAmsE.` or else wait until you
are on the UW internet before running this command.)

Upon connecting to Hyak, you will be prompted for your password; this is your
standard UW password. When you have entered it correctly, you will be prompted
for 2-factor authentication (2FA), just like when logging into any UW
service. Once you have completed 2FA, you should see a message that starts with
ascii art spelling out "klone hyak" and ends with a variety of information about
the cluster. From this point until you **`exit`** Hyak or lose connection, any
command you enter will go to Hyak instead of to your own computer.

(Official information about logging into Hyak can be found
[here](https://hyak.uw.edu/docs/hyak101/basics/login/).)


## (4) Configuring Hyak

So far you have configured your computer to make it easy to connect to
Hyak. However, Hyak also needs to be configured to make it easier to use. We
will do this in several steps.

Note that you only need to run these configuration steps once, no matter how
many different computers you use to connect to Hyak, because they are
configurations of Hyak itself and thus are independent of the computer used to
connect to Hyak.

### (4.1) Configure SSH on Hyak

The first thing we need to do is to configure SSH on Hyak. We need to do this
because we will use SSH not only to connect to Hyak itself but also to connect
to individual compute nodes on Hyak. When we run the command `ssh hyak`, we make
a connection to "klone," the so-called "head node" of the Hyak cluster. Because
Hyak is a cluster of computers, a single computer (klone) is assigned as a sort
of manager and user-interface point for the rest of the cluster. When we run
anything substantive, we don't want to run it on this computer; we instead want
to run it on one of the nodes (computers) that is powerful and optimized for
computation. To connect to these nodes, we use SSH, and we want to set up SSH so
that it doesn't require that we type a password each time we do this
(unfortunately, we can't do this for connecting to klone itself).

1. Make sure that the `.ssh` directory exists: **`mkdir -p ~/.ssh`**
2. Generate a public-private key pair: **`ssh-keygen -C "<NetID>@uw.edu" -t ed25519`**  
   This command will ask you a few questions; you may accept all of them as the
   default without typing any additional information into the
   prompts. Confusingly, one of the questions is for a password, which you
   should leave blank. You don't want to type a password every time you use this
   key to connect to another computer, and you don't need a password because you
   are the only user with permission to read the file containing the private key
   you are creating. If this command runs successfully it will end by printing
   out a weird looking ascii art picture that represents your key.
3. Authorize this key for connecting to compute nodes:
   **`cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys`**  
   This command puts a copy of your new public key at the end of the
   `authorized_keys` file, allowing you to use it for logging into compute nodes
   (the key will be used automatically once you have done this).
   
To test that the above steps were successful, you can run the following command:
**`ssh n3441`**. If this command prints something like the following, you have
configured SSH successfully:  
```
Warning: Permanently added 'n3441,10.64.66.185' (ECDSA) to the list of known hosts.
Access denied by pam_slurm_adopt: you have no active jobs on this node
Connection closed by 10.64.66.185 port 22
```  
If, on the other hand, the command asks you for a password, then something has
gone wrong with your SSH configuration. (The first line of the above message may
not be printed if you have run this command before.)

### (4.2) Install `hyak-jupyter`

The `hyak-jupyter` program allows one to easily use a Jupyter notebook over a
Hyak connection. You can install this program by using the repository containing
these instructions--it also contains the program itself and an installation
script. To do this, you will need to clone the repository on Hyak then run the
appropriate script.

If you are unfamiliar with git and GitHub, then I recommend reviewing the
[Software Carpentry lesson on Git and
GitHub](https://swcarpentry.github.io/git-novice/). You do not need to go
through all the steps for setting up Git and GitHub in order to follow these
steps, however.

1. I typically keep Git repositories in a subdirectory of my home directory
   called `repos` or `code`. To create this directory, first make sure you are
   in your home directory (command: **`cd`**) then: **`mkdir -p repos`**
2. Navigate into this directory using the `cd` (change directory) command:
   **`cd repos`**
3. Clone the repository: **`git clone https://github.com/noahbenson/i-focus`**  
   This will create a subdirectory of the `repos` directory named `i-focus` that
   contains this repository.
4. Navigate into the `i-focus` repository: **`cd i-focus`**
5. Run the installation script: **`sh hyak/setup.sh`**

The final command above should print a message stating that it was
successful. Once this has been run, you can use the `hyak-jupyter` command to
start a Jupyter instance (see below for more information).

### (4.3) Using Jupyter on Hyak

Once you have run the above setup instructions, you can start a Jupyter instance
by running the following command:
```bash
hyak-jupyter --time=<time>
```

In the command, the `<time>` should be the maximum amount of time you intend to
use the node (it's okay to ask for more time than you expect to use, but if you
have a good guess, then use that); for example, two hours would be
`--time=2:00:00`. You can also provide any argument that is typically provided
to the `srun` or `sbatch` commands; for example, you can request that the
allocation occur under a specific Hyak account with the option `-A
<account>`. (If you aren't sure of your account name, you can see all your
accounts using the `groups` command; `hyak-jupyter` will automatically pick one
for you if you don't provide it.) Fairly common options that you might want to
use includ requesting a different partition (via `-p <partition>`, such as `-p
ckpt-all`), a different amount of memory (via, e.g., `--mem=8G`), or a different
number of CPUs (e.g., `--ntasks-per-node=4`). These options are documented in
the `srun` command and additionally
[here](https://hyak.uw.edu/docs/compute/scheduling-jobs/).

Once you've run this command, a screen session will open. It may take awhile for
the jupyter session to be ready, especially if it is the first time you have run
it or if you haven't run it in awhile. Once it is ready, a line will appear
that says:  
```
To connect to Jupyter, point your browser to localhost:7777
```  
At this point, if you go to `localhost:7777` you should automatically connect to
the Jupyter server on Hyak.

Note that once you have started `hyak-jupyter`, it will run in a [GNU
screen](https://www.gnu.org/software/screen/manual/screen.html), which allows it
to continue to run when you are no longer connected to Hyak. You can detach the
screen (i.e., put the program in the background such that it is still running
but does not take up your terminal) by pressing control+a then d. To reattach
it, you can type `screen -x jupyter`. These instructions are also at the bottom
of the screen window. If you close your connection to Hyak itself, you will lose
connection to the Jupyter instance, but it will continue running for as much
time as you requested, so long-running jobs can be started in Jupyter then left
on Hyak in this way.


## (5) Using `hyakvnc`

Currently, the `hyakvnc` client is usable but not very useful. This section will
be updated once we have need of the `hyakvnc` tool.

