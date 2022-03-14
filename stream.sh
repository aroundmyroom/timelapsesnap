# this bash script was found on the Internet and changed to fit my needs on a Raspberry Pi 2B with a Unifi G3 Camera to live stream to Youtube
# it needed some small changes to keep running after a stream error and if there is a 'crash' can heal itself by restarting itself
# I do run this script in 'screen' to have control over it.
# do not forget to make this file executable ie. chmod 755 stream.sh ;)

for (( ; ; ))
do

# Various Variables are used for FFMPEG

STREAM_KEY="enter here your stream key from studio.youtube.com" # YouTube Stream Key

# enter here the RTSP source from the Protect application
RTSP_SOURCE="rtsps://[ip-address & URL from the camera"
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2" # Base YouTube RTMP URL
VBR="5200k" # Bitrate
USE_TCP=1 # Use TCP transport for RTSP, otherwise UDP
MUTE_AUDIO=1 # Discard audio from the camera 0 = Audio On, 1 = Audio off

# ffmpeg is needed and these are the Arguments used, including arguments to keep running the stream even when there are issues

args=()
(( USE_TCP == 1 )) && args+=( '-rtsp_transport tcp' )
args+=( '-i' $RTSP_SOURCE )
(( MUTE_AUDIO == 1 )) && args+=( '-f lavfi -i anullsrc' )
args+=( '-b:v' $VBR )
args+=( '-tune zerolatency' )
args+=( '-preset veryfast' )
args+=( '-vcodec libx264' )
args+=( '-pix_fmt +' )
args+=( '-c:v copy' )
args+=( '-c:a aac' )
args+=( '-drop_pkts_on_overflow 1' )
args+=( '-attempt_recovery 1' )
args+=( '-recover_any_error 1' )
args+=( '-strict experimental' )
args+=( '-f flv' $YOUTUBE_URL/$STREAM_KEY )

echo "Starting ffmpeg ${args[@]}"
ffmpeg ${args[@]}
# when there is a crash go back to the beginning to restart the stream
echo Crash
sleep 1
done
