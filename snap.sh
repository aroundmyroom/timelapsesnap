#!/bin/bash

SNAP_BASE="/home/snap"
OUT_DIR="$SNAP_BASE/timelapse"
DATE_EXT=`date '+%F %H_%M_%S'`
FRAMERATE=30
# new items for ffmpeg due to not using anonymous snap.jpeg anymore #
rtspTransport="tcp"
frameRate="1"
vsync="1"
duration="1"
quality="1"

declare -A CAMS

CAMS["Voordeur"]="rtsps://url-of-controller:7441/[check-in-Protect-and-replace-this]?enableSrtp"
CAMS["SlowTimeLapse"]="rtsps://url-of-controller:7441/[check-in-Protect-and-replace-this]?enableSrtp"

#If we are in a terminal, be verbose.
 if [[ -z $VERBOSE && -t 1 ]]; then
  VERBOSE=1
 fi

log()
{
  if [ ! -z $VERBOSE ]; then echo "$@"; fi
}

logerr() 
{ 
  echo "$@" 1>&2; 
}

createDir()
{
  if [ ! -d "$1" ]; then
    mkdir "$1"
    # check error here
  fi  
}


getSnap() {
  camName="$1"
  camURL="${CAMS[$camName]}"
  
  snapDir="$SNAP_BASE/$camName"
  createDir "$snapDir"
  
  snapFile="$snapDir/$camName - $DATE_EXT.jpg"

  log "Saving snapshot from '$camName' to '$snapFile'"

# the new camera's like the Unifi G5 Turret has low resolution SNAP.JPEG, you need to use FFMPEG to get higher resolution images

 ffmpeg -i "$camURL" \
         -rtsp_transport "$rtspTransport" \
         -r "$frameRate" \
         -vsync "$vsync" \
         -t "$duration" \
         -qscale:v "$quality" \
         "$snapFile" 

}



createMovie()
{
  snapDir="$SNAP_BASE/$1"
  snapTemp="$snapDir/temp-$DATE_EXT"
  snapFileList="$snapDir/temp-$DATE_EXT/files.list"
  
  if [ ! -d "$snapDir" ]; then
    logedd "Error : No media files in '$snapDir'"
    exit 2
  fi

  createDir "$snapTemp"

  if [ "$2" = "today" ]; then
    log "Creating video of $1 from today's images"
    ls "$snapDir/"*`date '+%F'`*.jpg | sort > "$snapFileList"
  elif [ "$2" = "yesterday" ]; then
    log "Creating video of $1 from yesterday's images"
    ls "$snapDir/"*`date '+%F' -d "1 day ago"`*.jpg | sort > "$snapFileList"
  elif [ "$2" = "file" ]; then
    if [ ! -f "$3" ]; then
      logerr "ERROR file '$3' not found"
      exit 1
    fi
    log "Creating video of $1 from images in $3"
    cp "$3" "$snapFileList"
  else
    log "Creating video of $1 from all images"
    `ls "$snapDir/"*.jpg | sort > "$snapFileList"`
  fi

  # need to chance current dir so links work over network mounts
  cwd=`pwd`
  cd "$snapTemp"
  x=1
  #for file in $snapSearch; do
  while IFS= read -r file; do
    counter=$(printf %06d $x)
    ln -s "../`basename "$file"`" "./$counter.jpg"
    x=$(($x+1))
  done < "$snapFileList"
  #done

  if [ $x -eq 1 ]; then
    logerr "ERROR no files found"
    exit 2
  fi

  createDir "$OUT_DIR"
  outfile="$OUT_DIR/$1 - $DATE_EXT.mp4"

  log "Starting ffmpeg"

#make sure you have a mp3 file long enough based on all your images. If your music file is too short, the timelapse will be short
#music not included in source

ffmpeg -fflags discardcorrupt -r "$FRAMERATE" -start_number 1 -i "$snapTemp/"%06d.jpg -i /home/snap/timelapse2024.mp3 -map 0:v:0 -map 1:a:0 -c:v libx264 -s hd1080 -preset slow -shortest -crf 18 -c:a copy -pix_fmt yuv420p "$outfile" -hide_banner -loglevel panic -stats


  log "Created $outfile"

  cd $cwd
  rm -rf "$snapTemp"
  
}


case $1 in
  savesnap)
    for ((i = 2; i <= $#; i++ )); do
      if [ -z "${CAMS[${!i}]}" ]; then
        logerr "ERROR, can't find camera '${!i}'"
      else
        getSnap "${!i}" "${CAMS[${!i}]}"
      fi
    done
  ;;

  createvideo)
    createMovie "${2}" "${3}" "${4}"
  ;;

  *)
    logerr "Bad Args use :-"
    logerr "$0 savesnap \"camera name\""
    logerr "$0 createvideo \"camera name\" today"
    logerr "options (today|yesterday|all|filename)"
  ;;

esac
