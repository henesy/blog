+++
title = "Using p9sk1 authentication in modern 9front"
date = "2018-12-27"
tags = [
	"plan9",
]
+++

# Using p9sk1 authentication in modern 9front

Many moons ago 9front moved to dp9ik auth from p9sk1 due to security concerns. However, there may be cases, such as using parts of plan9port, that one may want to enable the old cpu protocol and p9sk1 authentication.

Steps to complete:

- Enable p9sk1 by removing the `-N` flag from the authsrv(2) init scripts:
	- `/rc/bin/service.auth/authsrv.il566`
	- `/rc/bin/service.auth/tcp567`
- Enable the legacy cpu(1) protocol server via:
	- `mv '/rc/bin/service/!tcp17010' /rc/bin/service/tcp17010`

Assuming your auth/cpu server is otherwise configured correctly, you should be able to use [0intro's legacy drawterm](https://github.com/0intro/drawterm) to connect to your server as a proof of concept. 

Some useful configuration verification commands:

- `netaudit`
- `auth/debug`
- `auth/asaudit`

Some information on the auth differences is available: <http://9.postnix.pw/ref/auth_notes>

