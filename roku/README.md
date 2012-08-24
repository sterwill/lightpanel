# Building 

Roku applications (most of them, anyway) are written in an interpreted
BASIC-like language called BrightScript.  There's really no compilation
involved, just packaging the script files any resources (images, manifest)
into a ZIP archive that you can run on your Roku.

Applications going into the Roku Channel Store must be cryptographically
signed.  This is a process I haven't done, so these instructions 
skip those steps.  You'll have an package that can only be installed on a 
Roku in "developer mode", but it's really easy to do and there really
aren't any down-sides.

# Installing Light Panel HD

## Put your Roku in Development Mode

Press:

`HOME` 3 times, `UP` 2 times, `RIGHT`, `LEFT`, `RIGHT`, `LEFT`, `RIGHT`

Development mode lets you install unsigned applications and opens up the
debug console on TCP port 8085.

## On a Unix System with curl Installed

```export ROKU_DEV_TARGET=<your.roku.ip.address.or.hostname>
make install```

## On any Operating System

If you didn't install it with curl above, you can install it through
the Roku's web interface (that opens up in developer mode).

First build the `out/lightpanel.zip` package with:

```make```

Then open up the Roku web interface (running on your Roku on TCP port 80) 
and upload the package using the web page form.

# Hacking this Application

I did the original development in Eclipse with the Roku plug-in for
Eclipse, which gives you BrightScript syntax highlighting and helps
a bit with deployment and debugging.

Doing it from the command-line ("make install" to test) isn't really
much different.

# References

Trey Gourley has an [awesome guide to developing a basic Roku
channel](http://www.treygourley.com/2012/07/developing-a-basic-roku-channel/)
that I really wish was around when I wrote Light Panel HD.  The
article describes development mode, debugging, image dimensions, hosting,
uploading, and much more


Shaw Terwilliger <sterwill@tinfig.com>
