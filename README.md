update 10-03-2025:  [dd-mm-yyyy]
After a firmware aka controller update the http link is permanently moved to https with an 302 message.
as WGET is following this it will complain about the certificate, which is not there / not valid etc.. 
so wget --quiet --no-check-certificate -O "$snapFile" "$2" is now in place.
With this I have valid JPEGS again and my timelapses do work again (unfortunately missing 10 days of timelapses)


Update 23-04-2024: [dd-mm-yyyy]
I bought a Unifi G5 Turret Ultra and upon installation I saw that the export of the snap.jpeg was having a low resolution image (640x480)
as I cannot use that I found a solution by getting the image from the RTSP stream available from Protect through the controller.
I had to modify the snap.sh script and after some testing .. the new snap.sh was created.

The code is probably rubbish and badly written, but hey it works for me over 5 years now ;)

older notes:

Create live stream from Ubiquity UNIFI Cameras to Youtube or a Timelapse to Youtube
For livestream see the stream.sh bash shell script

# Timelapsesnap
Create Timelapse from Unifi G3 (flex) Camera through snap.jpeg
derived from: https://github.com/sfeakes/UniFi-Timelapse

A daily timelapse is uploaded by my to youtube channel (automatically) after this script has made the timelapse
see it here: https://www.youtube.com/playlist?list=PLYUJ8dQSre0TeUd91iiCcnz17_Y1kDmBQ

Needs:
snap.jpeg has been replaced, so you now need to use the RTSP link provided by Protect.

Obsolete with this newer snap.sh:
Unifi G3 (Flex) camera with public snap.jpeg option (to be set in the camera) (no username/password)
Extra info: the snap.jpeg cannot be set in Protect, but only in the UI of the camera. so Login to the camera with username ubnt and your password


FFMPEG
Some scripting skills (i have little, so it must be do-able)

License should be considered Public Domain as it is derived from above github source ;)

I have renamed the script snap.sh

ie
/home/snap/snap.sh savesnap "Voordeur"

The above option should save a still image to the directry listed in the SNAP_BASE variable. 

This example in crontab is to save an image every minute

`*/1 * * * * /path/to/script/snap.sh savesnap "Voordeur" "Achterdeur"`

./snap.sh createvideo "defined Camera name" today
That will create a time-lapse of all todays images. Options are today yesterday all file hopefully that’s self explanatory.

It depends what kind of timelapse you want, this script is optimized to get every x seconds an image as this gives better results when
capturing clouds during 1 or 2 days. 

This example gets every 30 seconds 1 image

`* * * * * /bin/bash -c ' for i in {1..2}; do /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1 ; sleep 30 ; done '`

Explained:

`* * * * * /bin/bash -c ' for i in {1..X}; do /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1 ; sleep Y ; done '`

If you want to run every N seconds then X will be 60/N and Y will be N.

This example gets every 1 minute 1 image

`*/1 * * * * /path/to/script/snap.sh savesnap "Voordeur" "Achterdeur"`

`*/1 7-18 * * * /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1`

In this example: Get every minute an image between 07.00 and 18.00 hours (if you do not want to capture dark periods)

Main command to create a video:
./snap.sh createvideo "defined Camera name" today|yesterday|all|file

example:
./snap.sh createvideo "Voordeur" all
The file option should be a text file with a list of the images you want included, one per line.
