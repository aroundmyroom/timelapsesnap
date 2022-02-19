Example code what I have in my script

cd /home/snap/Voordeur

find . -maxdepth 1 -type f -size 0 -delete
cd $SNAP_BASE

/home/snap/snap.sh createvideo "Voordeur" yesterday

cd /home/snap/timelapse/

// comment.
touch test.txt

copy files from location to another mount location for other purposes like youtube video

for youtube I use the linux youtube-upload shell software. PS you need to enable and use the correct 'keys

in the file .youtube-upload-credentials.json

// end comment (remove lines above)


cp * /media/timelapse/timelapse/

rm *

for f in /media/timelapse/timelapse/*.mp4; do /usr/bin/python3.7 /home/snap/youtube-upload/bin/youtube-upload --title="title here $NOW" "$f" --playlist="Timelapse" --description="extra info";done

cd /media/timelapse/timelapse

cp * /media/timelapse/timelapse-backup

rm *

cd $SNAP_BASE/Voordeur

find /home/snap/Voordeur -type f -name '*.jpg' -daystart -mtime +1 -exec rm {} \;

