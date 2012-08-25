# Building 

Roku applications (most of them, anyway) are written in an interpreted
BASIC-like language called BrightScript.  There's really no compilation
involved, just packaging the script files any resources (images, manifest)
into a ZIP archive that you can copy to your Roku.

Applications in the Roku Channel Store must be cryptographically
signed.  This is a process I haven't done, so these instructions 
skip those steps.  You'll have an package that can only be installed on a 
Roku in "developer mode", but it's really easy to do and there really
aren't any down-sides to enabling it.

# Installing Light Panel HD

## Put your Roku in Development Mode

Press:

`HOME` 3 times, `UP` 2 times, `RIGHT`, `LEFT`, `RIGHT`, `LEFT`, `RIGHT`

Development mode lets you install unsigned applications and opens up the
debug console on TCP port 8085.

_Make a note of your Roku's IP address._

## On a Unix System with make, zip, and curl

```bash
export ROKU_DEV_TARGET=<your.roku.ip.address.or.hostname>
make install
```

That should do it.  Make will build `out/lightpanel.zip` with zip
and upload it to your Roku.

The application should start immediately.

## On any Operating System 

You can install a pre-built release package from the `../release` 
directory without make, zip, and curl installed.  Just visit your 
Roku's web server (running on TCP port 80) in your favorite web 
browser and upload the `out/lightpanel.zip` file with the web form.

That's it!

# Screensaver

To use Light Panel HD as a screensaver (it's really good for this!)
just go into the system settings and choose it.

# Hacking this Application

I did the original development in Eclipse with the Roku plug-in for
Eclipse, which gives you BrightScript syntax highlighting and helps
a bit with deployment and debugging.

Doing it from the command-line ("make install" to test) isn't really
much different.

My basic development routine is simply:

1. Make changes to source code
2. `make install`
3. Test your changes
4. Go to step 1

# References

Trey Gourley has an [awesome guide to developing a basic Roku
channel](http://www.treygourley.com/2012/07/developing-a-basic-roku-channel/)
that I really wish was around when I wrote Light Panel HD.  The
article describes development mode, debugging, image dimensions, hosting,
uploading, and much more


Shaw Terwilliger <sterwill@tinfig.com>
