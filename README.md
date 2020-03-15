# video-manager
This simple crystal program will loop over the list of directories you tell it
to via the config file. For each video file in the directory, it will optimize
the file according to the ffmpeg encoding settings listed in your config file.
Each file is copied to /tmp before conversion begins, and all file changes
are done atomically, meaning the program can be interrupted at any point and
you won't corrupt or lose any data. You can also configure the number of
parallel conversions that will run at once. The default ffmpeg settings
are designed to allow for fast seeking on a Plex server.

The program will save the hashes (based on filename, file size, and the ffmpeg
options that were used) of each file it has already optimized in the config
file so if it is re-run those same files will not be converted again. If you
make a change to your ffmpeg options, all files will be re-converted since
their hashes will be invalidated.

On a very good CPU (i.e. a 9900k), 8 threads seems to be the sweet spot.

The config file is located at `~/.video-manager-settings.json`
