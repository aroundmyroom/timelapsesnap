# timelapsesnap
Create Timelapse from Unifi G3 (flex) Camera through snap.jpeg
derived from: https://github.com/sfeakes/UniFi-Timelapse

License should be considered Public Domain ;)

I have renamed the script snap.sh

ie
/home/snap/snap.sh savesnap "Voordeur"

The option should save a still image to the directry listed in the SNAP_BASE variable. 
If it woked setup a cron job to execute that script every time you want to save an image.
This example is crontab to save an image every minute

`
*/1 * * * * /path/to/script/snap.sh savesnap "Voordeur" "Achterdeur"
`

./snap.sh createvideo "defined Camera name" today
That will create a time-lapse of all todays images. Options are today yesterday all file hopefully that’s self explanatory.

It depends what kind of timelapse you want, this script is optimized to get every x seconds an image as this gives better results when
capturing clouds during 1 or 2 days. 

This example gets every 30 seconds 1 image
`
* * * * * /bin/bash -c ' for i in {1..2}; do /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1 ; sleep 30 ; done '
`
Explained:

`* * * * * /bin/bash -c ' for i in {1..X}; do /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1 ; sleep Y ; done '`

If you want to run every N seconds then X will be 60/N and Y will be N.

This example gets every 1 minute 1 image
`
*/1 * * * * /path/to/script/snap.sh savesnap "Voordeur" "Achterdeur"
`
`
*/1 7-18 * * * /home/snap/snap.sh savesnap "Voordeur" > /dev/null 2>&1
`

In this example: Get every minute an image between 07.00 and 18.00 hours (if you do not want to capture dark periods)

Main command to create a video:
./snap.sh createvideo "defined Camera name" today|yesterday|all|file

example:
./snap.sh createvideo "Voordeur" all
The file option should be a text file with a list of the images you want included, one per line.
