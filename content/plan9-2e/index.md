+++
title = "Install Notes for Plan 9 Second Edition"
date = "2018-03-19"
tags = [
	"plan9",
]
+++

# Install Notes for Plan 9 Second Edition

A thanks to aap for providing copies of the floppy images and isos used to perform the test installs. None of this would have been able to happen without you.

Disclaimer: I have not successfully managed to get Plan 9 2e (2e from hereon) installed in qemu or physical hardware. Qemu has had issues due to the fact that I'm unfamiliar with configuring IDE in qemu. If anyone figures out how to install 2e in qemu, please let me know.

Some useful references before starting:

* [2e INSTALL file](http://doc.cat-v.org/plan_9/2nd_edition/install)
* [ISO files](http://plan9.eu/iso)
* [My 2e archive](http://9.postnix.pw/hist/2e)
* [Demo install video](https://www.youtube.com/watch?v=nc4LHV-QdZU)
* [Full install video](https://www.youtube.com/watch?v=W00TnQ91nj8)

In general, the 2e install process breaks down into the following steps:

1. Burn floppies (and cd, if desired)
2. Install MS-DOS
3. Install diskettes 1-4
4. Install from cd (if desired)

If you have the space and ability, I recommend doing the full post-demo install. 

## 1. Burn floppies

Diskette 1 is easy, you will write it directly to a floppy disk or just boot the .img as it ships. For diskettes 2-4 you will have .vd files that must be copied (not written) to dos-formatted floppy images or disks. 

Note: These instructions assume a linux host.

To create a formatted floppy image: 

```text
mkfs.msdos -C disk.img 1440
```

To mount a floppy image:

```text
mount -o loop disk.img /path/to/somedir
```

From this point you'd make .img's for the disk[2-4] .vd's and copy the respective file onto the image. 

If you need to create floppy images from DOS disks at this time, you can do:

```text
dd bs=512 count=2880 if=/dev/fda of=dos.img
```

## 2. Install MS-DOS

You can choose (probably) any 6.xx+ version of DOS up to Windows 95, but I've only tested the installation with MS-DOS 6.2. FreeDOS or DrDOS might work, but again, I haven't tested them. 

The required size for a demo install is pretty small, you can probably stick with DOS defaults if you just want to make a demo installation. If you want a full installation, you will need to install DOS on a 1GB+ partition (recall that DOS can't handle disks/partitions greater in size than 2GB) or so. The full installation will copy the entire contents of the cd (~500MB) and you will have a full demo installation in addition to this.

Perform the DOS installation by following the prompts, nothing special needs to be done here.

Note: DOS does not need cd drivers as the drivers come from the disk1 image. As such, you are limited with hardware you can use by the supported ware provided in the 2e installer. Good luck.

## 3. Install diskettes 1-4

Load and boot into disk1. 

You should be prompted for a disc to install to, in my case `/dev/hd0`. Then select the primary DOS partition (Probably partition 0). Select `Proceed` when prompted whether to install or not. Diskette 1 will then copy some files to the DOS partition.

When prompted for configuring installation, note that options not explicitly configured will not be written to the plan9.ini file generated. That is, there are no defaults. Configuring extra options you're not sure about shouldn't hurt anything, but if you select a video mode that is unsupported on your video card (emulated or otherwise), the GUI will fail to start and you'll have to boot into disk1 to reconfigure your system (reconfiguring through disk1 is the encouraged method for fixing bad plan9.ini's regardless). 

My configuration looked something like this: 

* 'VGA setup' → 800x600x1 → vga (using …x8 broke graphics for me even though …x1 worked fine)
* 'Mouse type' → PS2
* 'ATA (IDE) controller' → secondary - Port 0x170 → IRQ 15 (this is how I used my cd drive for the full install with the drive configured as IDE's Secondary Master)
* 'File system console' → CGA

Once configured, save the plan9.ini when prompted and reboot into DOS. 

Run `plan9\b`. Select option [1] for Diskette System installation. You'll be prompted to load each diskette in series, as per usual. Once installation is finished, select 'Make the newly installed Plan 9 the default' and then select 'Reboot'.

Load and boot into disk1.

Go through the configuration process as before. After the configuration is complete you will be prompted to set a default configuration for your Plan 9 installation. Select 'An active Plan 9 system' then select your disk with DOS and Plan 9 installed. Reboot into DOS.

Run `plan9\b`. Congratulations, you now have a working Plan 9 Second Edition demo installation installed! If all you wanted was to install the demo, you can stop here. If you wish to create a full 2e installation, continue to the next section. 

## 4. Install from cd

Now that all the hard work is out of the way, the cd install is pretty simple.

Note: If at any point you are prompted with a warning about overwriting an existing Plan 9 installation, don't mind it. Overwriting is intended during the installation phases.

Boot back into disk1 and reconfigure your install to point to the correct IDE or SCSI drive where your cd will be loaded and set the install mode to 'File System Installation' when prompted. 

Note: From VirtualBox I had configured my cd drive on IDE to be Secondary Master. When configuring the installer, I had selected `IDE → Secondary → IRQ 15` and the disk1 installer was able to find the cd drive.

Boot into DOS and run `plan9\b`. Make sure the cd is inserted. Selection option [2] for installing from cd, when prompted for the location of the cd, navigate to the correct device 

Assuming you have sufficient space for the installation, the installer should copy all the files off of the cd. you will be prompted to 'Make the newly installed Plan 9 the default', select this and then 'Reboot'.

Once the copying is done, reboot into disk1 and reconfigure your install and set the install mode to 'An Active Plan 9 System'. Reboot.

From DOS run `plan9\b`, when prompted for a user enter `tor`. There is no `none` user by default from the cd, this is an old mistake. 

Instructions for adding the user are in the INSTALL document from the top list of references.

Congratulations, you have a full installation of Plan 9 Second Edition, please enjoy responsibly. 

