+++
title = "DiscordFS —- A Tale of Two Clients"
date = "2018-05-24"
tags = [
	"go",
	"9p",
]
+++

# DiscordFS -- A Tale of Two Clients

Around a year ago I worked on my first attempt at a [Discord](https://discord.gg) [client](https://bitbucket.org/henesy/disco) that would build and function on 9front. Since then the landscape hasn't changed much and neither has the client. It works well enough for my needs and the two or so other people who use it. Since then however, the number of members in the [9fans Discord Server](https://discord.gg/eu8VBUs) has grown many times its original size. Summarily, the interest in a native client for 9front grew to scale. The problem is that for Discord to be experienced fully as intended, it demands a GUI. Plan 9 fits the bill well for this as the GUI model is very intuitive and the graphical use of the system is encouraged at every turn. The problem is that the Go language used for the client is not only a slight bit unreliable on Plan 9, but is not the native language of the system. A concession has been made as to where the Discord [library](https://github.com/bwmarrin/discordgo) used is fairly robust and well maintained, so we didn't want to abandon it, but we wanted to use C to fit the 9front software standards people expect. 

The solution is a filesystem. What follows is the rough format of such a filesystem, outlining how such a filesystem would be laid out. DiscordFS could be run as a client on its own and be in Go, though it would not be very intuitive. The idea model for a native 9front client would be a C program which expects a filesystem interface for Discord (provided by DiscordFS) and then handles graphical display and processing of user input complete with colors and images as per the Electron Discord client. 

## Structure

As always, input is much appreciated. Feel free to pitch in on the conversation via the [9fans Discord Server](https://discord.gg/eu8VBUs).

```text
/
	henesy/
		...
	heneinesy/
		9fans/
			ctl
			roles
			about
			channels/
				general/
					ctl
					messages
					about
				...
			members/
				mveety/
					ctl
					roles
					about
				mora/
				...
		r40k/
			...
	...
```

* ctl -- A file which allows documented commands to be run and operated against a given element (add/remove/change permissions)
* messages -- Dynamically loads the last N messages for a channel as they're read depending on the ctl configuration
* about -- Displays general, parseable, information about a given element
* attachments -- A directory containing files that were attached to messages. The messages folder, when a file is attached, can have special syntax to denote that a message is attached and what its filename and hash are. 

In this case `/` is the top directory in the mounted fs with subfolders for each user and then for each user subfolders for each server they are a member of, etc.

