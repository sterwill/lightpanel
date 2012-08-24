# Image Resolutions

Light Panel only supports HD resolution (1280x720) on the Roku.  Finding
high quality source images is difficult, and I picked images framed
for wide-screen display.  Cutting out SD-sized pictures from these
sources didn't give me a satisfactory result, so I decided to work
only with wide-screen images.

However, the generator and source code are _mostly_ ready for SD 
images.

Things to keep in mind if you want to hack SD into this project:

- Roku HD resolution is 1280x720 with a square (1:1) pixel aspect ratio.
- Roku SD resolution (in this program) is 640x480 with a square (1:1) 
  pixel aspect ratio.

Normal SD NTSC content on the Roku is 720x480 with a 1.1:1 ratio, but
lightpanel chooses the square pixel mode for SD content.  This makes
image maintenance easier.

# Incorporating New Images

To work a new image into the program:

## Essential Steps

- Create an HD GIMP file at 1280x720 (16:9), and do all the lighting
  and overlay work there.

- Create a "background" layer that takes the whole image area and
  has all the lights OFF.  Use the dodge/burn and clone tools.

- Create an "overlay" layer that has all the lights ON.  Again,
  use the dodge/burn and clone tools, or draw them yourself and
  paint them in (I did that for the Nova 3 image based off other
  low resolution images I found).

- Delete/clear all the image data in the "overlay" layer that
  isn't the lights and immediate area.  This really reduces the 
  overlay image size when saved as JPG.

- Export the "background" and "overlay" layers as JPG with ~85% quality
  (go higher if you need to, lower if you can).  Save these in 
  ../images and make sure you follow the nameing conventions.

- Make only the "overlay" layer visible, select it, and use GIMP's 
  Filters > Web > Image Map tool to select rectangular areas 
  around lights.

  - Don't select any of the area you deleted in that previous step
  - Include surrounding glow or reflection for a light
  - Save the map as file.xcf.map
  - Use map2code to generate a chunk of BrightScript from the map file
    (you can do this at any time later)

Now go hack the code to add a new model that uses the two JPG
images you exported and the region code from map2code.  You're nearly
done.

# Debuging Tips

- I recommend doing all your coding and testing with the HD image set 
  before doing any SD work.

- To build the SD resources, create a copy of the HD GIMP file for SD, 
  and rework it down to a 640x480 (crop and/or resize).  Remember that
  SD televisions usually have massive overscan.

  To preserve all the vertical image data, first crop to 960x720, then
  resize to 640x480.
    
- Now repeat the image map steps you did for the HD image.  This
  is a bit tedious.  I guess you could calculate the new numbers 
  from the old ones if you know how you cropped your image,
  but there might be rounding errors.

- Don't forget to "git add" all the .xcf, -sd.xcf, .map, and .jpg
  files.

Shaw Terwilliger <sterwill@tinfig.com>
