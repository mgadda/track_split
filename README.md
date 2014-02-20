Description
===========

Split audio files using ffmpeg into multiple files according to track list.

Prerequisites
=============

Track list must be text file containing one line for each track as follows:

```
Track 1 -- 00:00
Track 2 -- 04:32
Track 3 -- 06:23
```

ffmpeg must be present in your PATH. 

Running Track Split
===================

`./split.rb some_audio_file.mp3 track_list.txt`

Upon successful execution, a directory with the same name as the audio file (minus the extension) will be created in the current working directory and the individual tracks will be written to that directory. 
