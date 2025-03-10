#!/bin/bash

SNAP_BASE="/home/snap"
OUT_DIR="$SNAP_BASE/timelapse"
DATE_EXT=`date '+%F %H_%M_%S'`
FRAMERATE=30

declare -A CAMS

# Add the IP of your Cams (Only for Unifi G3 or lower)

CAMS["Voordeur"]="http://10.1.1.x/snap.jpeg"
CAMS["SlowTimeLapse"]="http://10.1.1.x/snap.jpeg"
#CAMS["Driveway"]="http://192.1.1.x/snap.jpeg"
#CAMS["Back Garden"]="http://192.1.1.x/snap.jpeg"

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

  snapDir="$SNAP_BASE/$1"
  if [ ! -d "$snapDir" ]; then
    mkdir -p "$snapDir"
    # check error here
  fi
  
  snapFile="$snapDir/$1 - $DATE_EXT.jpg"

  log savingSnap "$2" to "$snapFile" 

#  wget --quiet -O "$snapFile" "$2"
   wget --quiet --no-check-certificate -O "$snapFile" "$2"
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
#   ffmpeg -r 15 -start_number 1 -i "$snapTemp/"%06d.jpg -c:v libx264 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p "$outfile" -hide_banner -loglevel panic
##    ffmpeg -r "$FRAMERATE" -start_number 1 -i "$snapTemp/"%06d.jpg -c:v libx264 -s hd1080 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p "$outfile" -hide_banner -loglevel panic
ffmpeg -fflags discardcorrupt -r "$FRAMERATE" -start_number 1 -i "$snapTemp/"%06d.jpg -i /home/snap/timelapse2024.mp3 -map 0:v:0 -map 1:a:0 -c:v libx264 -s hd1080 -preset slow -shortest -crf 18 -c:a copy -pix_fmt yuv420p "$outfile" -hide_banner -loglevel panic -stats
#   ffmpeg -r 24 -start_number 1 -i "$snapTemp/"%06d.jpg -i -s hd1080 -vcodec libx264 -c:v copy -pix_fmt yuv420p "$outfile" -hide_banner -loglevel panic


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
