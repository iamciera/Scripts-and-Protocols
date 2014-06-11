# Guide to Working in iPlant

##Overview

These are the steps you must take *before* you can begin to process your data.

1.  Sign up for iplant
2.  Request Volume with greater storage (~100 GB per lane)
3.  Mount iplant Volume
4.  Mount IRODS Volume (for data storage)

#Iplant Atmosphere

Sign up for iplant using an educational e-mail.  After logging in go to Atmosphere and start an instance, in this case I used Maloof08. 

Can take up to 30 min. You will get an email verifying that your instance is up and running.  Then you can proceed.

##SSH connection 

There are two ways in which you can interact with your iplant enviroment. 1. Command line on your own desktop. This is faster, especially if you are familiar with command line.  I also like using this option because I have more control over my terminal appearance and keyboard shortcuts 2. The other option and more frequently used option is  to have a virtual desktop running through VNC viewer.  Overall it is easier to use the VNC viewer, mostly because you can allow programs to run without worrying about disconnecting ssh, which can stop longer programs from running. 

###1. using command line

To connect through ssh use  

    ssh youriplantusername@IP.address

You get the iplant ip address from your atmosphere desktop. After your instance begins to run, it will display the IP address right under the status or from the email you get when your instance is ready.

![IP.Address](./img/img1.png)

For example:

    ssh iamciera@128.196.64.108

They will ask for your iplant password. 

Now you are remotely connected to your iplant instance.  Use normal Unix commands to navigate your instance file directory system. 

##To transfer files between your computer to your iplant instance

To transfer files you simply use [`scp`](http://linux.die.net/man/1/scp).  

    scp location/of/file/to/transfer location/to/put/file

For example:

    scp /Users/iamciera/Desktop/RNAseqAnalysis/sinhaLab/Barcode-tools-3.2.tgz iamciera@128.196.142.74:~/Desktop/

 It will require your iplant password. 

or if you need to do it from server to local do the opposite.

    scp iamciera@128.196.142.74:~/Desktop/ /Users/iamciera/Desktop/RNAseqAnalysis/sinhaLab/Barcode-tools-3.2.tgz 

##How to Attach extra space to instance

##Volumes 

[How to attach a volume](https://pods.iplantcollaborative.org/wiki/display/atmman/Attaching+a+Volume+to+an+Instance)

Drag and attach on the atmosphere dashboard.

To create the file system type into terminal, this you only need to do once. 

    sudo /sbin/mkfs /dev/sdb #the "sdb" is specific to the volume that is given.  You can find it after you drag attach.

Now you must mount the file system to the partition. 

Mount filesystem

    sudo mount /dev/xvdb ~/lcm #volume and where you want to mount voulme, you may need to create the directory first if it does not already exisit.  

To check harddrive space and see if the mounting worked

    df -H

To unmount

    sudo umount /mydata

To quit

    command + D

##IRODs ("Unlimited GB")

IRODS is where you want to backup everything.  It is a good idea to back up the raw files right away. IRODS is another file directory in which you have access to.  You mount IRODS similarly to how you would mount an iplant volume, but you access it differently, through Icommands, which is basically regular unix commands with the an "i" in front.  

In order to use IRODS there are two steps. 

[Mounting IRODS](https://pods.iplantcollaborative.org/wiki/display/start/Mounting+the+iPlant+Data+Store+using+FUSE)

[Using Icommands](https://pods.iplantcollaborative.org/wiki/display/start/Using+icommands)

###Uploading multiple files or a directory (with recursion)

    iput -P -V -b -r -T -X <checkpoint-file> --lfrestart <checkpoint-lf-file>  localDirectory dataDirectory

For example this is how I backed up all of my work so far when analyzing lane1

    iput -P -V -T -r ~/lcm /iplant/home/iamciera/analyses

If you want to get files from irods simply use iget in a similar way. For example.

    iget -P -V -T -r /iplant/home/iamciera/analyses ~/lcm



##FTP download of Berkeley files 

[*MAC FTP tutorial*](http://www.maclife.com/article/howtos/how_use_ftp_through_command_line_mac_os_x)

Example: 

ftp: islay.qb3.berkeley.edu 
login: GSLUSER
psswd: B206Stanley
directory: /VCGSL_FTP/140204_HS3B

Open terminal in iplant and type in 

    ftp islay.qb3.berkeley.edu

Enter your user name and password.  You should see:

    ftp> 

iplant only works in FTP passive mode. So switch to passive mode. 

    passive

Then change to the directory where the file is

    cd /VCGSL_FTP/140204_HS3B

The further directory is under the PIs name, in this case, of course, Sinha. In there should be a folder that contains fastq.gz files.  

Turn off interactive mode, so you don't have to approve every file transfer.

    prompt

Use the mget command with wildcard to specify to download all. 

    mget * ~/Desktop

To quit the FTP connection

    quit

mget * ~/Desktop

##Permission settings

    sudo chown iamciera /home/iamciera/lcm

##Running and Interacting with Processes
From Vince's Book

To run a program in the background include ampersand in the background.

    program1 input.txt > results.txt &
    [1] 26577

The number returned by the shell is the process ID or PID of program1. This is a unique ID that allows you to identify and check the status of program1 later on. We can check what processes we have running in the background with jobs:

    $ jobs
    [1]+  Running                 program1 input.txt > results.txt

Bring to forground

    $ fg #brings up one if only one or list if more than one job is running.
    $ fg %1 #specifying the number in the job list

Place in Background. To do this, we need to suspend the process, and then use the bg command to run it in the background. Suspending a process temporarily pauses it, and allows you to put it in the background. We can suspend processes by sending a stop signal through the key combination control and z (at the same time). For example - 

    $ program1 input.txt > results.txt # forgot to append ampersand
    # enter control-z
    [1]+  Stopped                  program1 input.txt > results.txt
    $ bg
    [1]+ program1 input.txt > results.txt

##Running Programs where disconnecting ssh could happen

    disown -h a %job #maintain ownership until you disconnect.  This only works when the job is running in the background.

When you get back and connect to you can view if your program is still running with 

    ps -ef | grep "bwa" #to find whatever job you are running

or interactive process viewer

    htop

To look at all the programs running. 

But how do you know if the program/command ran successfully?  One way to make sure that a program successfully runs is to have your standard err and standard out output into log and error files when you run the command.

First you have to make standard error and standard out put files, then you can say to output to those files when you run the command. 

    command > file.log 2> file.err &

Cody suggested I use [GNU Screen](http://www.gnu.org/software/screen/).  But I haven't looked into that just yet.

##Basic Unix and Tools

    ls -l -h #list long human readible

To read the number of sequences in each fastq file

    $ LINES=`cat in.fasta | wc -l`
    $ READS=`expr $LINES / 4`
    $ echo $READS

To translate or replace files
In this example we are replacing '/r' with '/n' in BCfile.txt into a new file BCfile1.txt

    tr '\r' '\n' < BCfile.txt > BCfile1.txt 

When running a command is there a way that I can print the run time when it finishes? 

Look up `mosh` it is a different from ssh

Yes. When running a command add time to the end.

    time 

I need to seriously figure out bin and usr folders. 
[usr_bin](http://www.linfo.org/usr_bin.html)

##Permissions

In order to change the permission of an entire directory use chown. In the example below we are allowing to change owner recursively through all sub directories to the owner iamciera of the directory Data.

    sudo chown -R  iamciera Data/








