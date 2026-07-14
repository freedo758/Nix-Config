

# This script looks for video files in a specified directory and re-encodes them to codecs selected by the user.
# You're free to distribute it, modify and all that jazz.

# Media folders

# Input folder - here you put videos that you want to convert
media_in="/home/leo/Videos/convert_queue"

# Output folder - directory for storing converted videos
media_out="/home/leo/Videos/converted"

# The number of videos in the input folder
total="$( ls -A $media_in | wc -l )"

# Desktop notifications

# Specify what icons to use
icon_success=""
icon_error=""

notify_success () {
	notify-send -i $icons_dir/$icon_success "$1" "$2"
}

notify_error () {
	notify-send -u critical -i $icons_dir/$icon_error "$1" "$2" 
}

# Display the main menu

echo "--------------------------"
echo "What would you like to do?"
echo "--------------------------"
echo "1) Import an incompatible video"
echo "2) Render the final video"
echo "3) Exit the script"

# Store user input in a variale
read main_choice

case $main_choice in
	1)  # Set input codecs that will be converted
		input_codecs=("h264" "hevc")

		# Display the codec selection menu
		echo "-----------------------------------------"
		echo "Select the output codec for queued videos"
		echo "-----------------------------------------"
		echo "1) DNHXR HQX"
		echo "2) AV1"
		echo "3) MPEG-4 part 2"

		# Store user input in a variable
		read encoder_choice

		# Set ffmpeg arguments depending on the selected codec
		case $encoder_choice in
			1)  # DNXHR HQX
				video_enc="-c:v dnxhd -profile:v 4 -pix_fmt yuv422p10le"
				# Replace the above variable with the one below if you don't need 10-bit color depth
				# video_enc="-c:v dnxhd -profile:v 3 -pix_fmt yuv422p"
				out_format="mov"
				;;
			2)  # AV1
				video_enc="-c:v libsvtav1 -preset 6 -crf 23 -pix_fmt yuv420p10le"
				out_format="mp4"
				;;
			3)  # MPEG-4 part 2
				video_enc="-c:v mpeg4 -q:v 2"
				out_format="mov"
				;;
			4) echo "Exiting..." ; exit 0;;
			*) notify_error "You entered an invalid value" "Try running the script again." ; exit 1;;
		esac
		;;
	2)  # Set input codecs that will be converted
		input_codecs=("dnxhd" "prores")

		# Display the codec selection menu
		echo "-----------------------------------------"
		echo "Select the output codec for queued videos"
		echo "-----------------------------------------"
		echo "1) H.264"
		echo "2) H.265"
		echo "3) AV1"

		# Store user input in a variable
		read encoder_choice

		# Set ffmpeg arguments depending on the selected codec
		case $encoder_choice in
			1)  # H.264/AVC
				video_enc="-c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -x264-params opencl=true -movflags +faststart"
				out_format="mp4"
				;;
			2)  # H.265/HEVC
				video_enc="-c:v libx265 -preset slow -crf 20 -movflags +faststart"
				out_format="mov"
				;;
			3)  # AV1
				video_enc="-c:v libsvtav1 -preset 3 -crf 25 -pix_fmt yuv420p10le -svtav1-params tune=0:fast-decode=1 -movflags +faststart"
				out_format="mp4"
				;;
			4) echo "Exiting..." ; exit 0;;
			*) notify_error "You entered an invalid value" "Try running the script again." ; exit 1;;
		esac
		;;
	3) echo "Exiting..." ; exit 0;;
	*) notify_error "You entered an invalid value" "Try running the script again." ; exit 1;;
esac

# Check if ffmpeg is installed on the user's system
if ! command -v ffmpeg &> /dev/null; then
	notify_error "FFmpeg not found" "You need to install ffmpeg to use this script."
	exit 2
fi

# Create input and output directories (won't be an issue if they already exist)
mkdir -p $media_in $media_out

# Check if input directory is empty
if [[ -z $(ls -A $media_in ) ]]; then
	notify_error "The queue is empty" "There are currently no videos in the queue."
	exit 3
fi

# Encoding

file_index=0

for file in $media_in/*; do
	
	# Set additional variables for each video file
	file_name="$(cut -c $((${#media_in} + 2))- <<< "$file")"
	container_format="$(cut -c 7- <<< "$(file -b --mime-type $file)")"
	video_codec="$(ffprobe -v error -show_entries stream=codec_name -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 $file)"
	audio_codec="$(ffprobe -v error -show_entries stream=codec_name -select_streams a:0 -of default=noprint_wrappers=1:nokey=1 $file)"
	frame_rate="$(cut -c -2 <<< "$(ffprobe -v error -show_entries stream=avg_frame_rate -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 $file)")"
	keyframe_interval="$(($frame_rate * 10))"
	
	# Update ffmpeg arguments for AV1 encoder based on a video's framerate
	if [[ $enc_sel -eq 2 ]]; then
		video_enc="$video_enc -g $keyframe_interval"
	fi
	
	# Set file extension of the input video based on it's container format
	case $container_format in
		"mp4") file_ext=".mp4";;
		"quicktime") file_ext=".mov";;
		"x-matroska") file_ext=".mkv";;
		"webm") file_ext=".webm";;
		*) notify_error "Unrecognized file format" "Couldn't convert $file_name." ; exit 4;;
	esac

	# Set ffmpeg arguments for encoding audio based on the file's audio codec
	if [[ $audio_codec == "aac" ]]; then
		audio_enc="-c:a pcm_s16le"
	else
		audio_enc="-c:a copy"
	fi

	# Convert the videos
	if [[ "${input_codecs[*]}" =~ "$video_codec" ]]; then
		file_index=$(( $file_index + 1 ))
		notify_success "Converting... $file_index/$total"
		foot ffmpeg -i $file $video_enc $audio_enc $media_out/$(basename $file_name $file_ext).$out_format
	fi
done

# Send a desktop notification once the conversion is finished
notify_success "Converting finished" "The videos have been successfully converted."

