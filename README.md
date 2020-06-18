# Blog

This is the hugo repository for the blog at seh.dev.

This repository is the source for the contents shown in the pages repository at https://github.com/henesy/henesy.github.io.

## Install hugo

	git clone https://github.com/gohugoio/hugo
	cd hugo
	go install --tags extended

## Build the blog

	git clone --recurse-submodules https://github.com/henesy/blog
	cd blog
	hugo server --disableFastRender
	# Follow hugo instructions for viewing the rendered content

## References

- https://gohugo.io/hosting-and-deployment/hosting-on-github/
- https://gohugo.io/getting-started/installing/
- https://gohugo.io/getting-started/usage/
