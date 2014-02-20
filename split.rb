#!/usr/bin/env ruby

require 'fileutils'

class Track
  attr_accessor :name, :start_time
end

class TrackTime
  attr_accessor :minutes, :seconds

  def initialize(time)
    if time.kind_of?(String)
      @minutes, @seconds = time.split(":").map(&:to_i)
    elsif time.kind_of?(Fixnum)
      @minutes = time / 60
      @seconds = time % 60
    end
  end

  def to_s
    "%02d:%02d" % [@minutes, @seconds]
  end

  def -(another_time)
    TrackTime.new(self.total_seconds - another_time.total_seconds)
  end

  def +(another_time)
    TrackTime.new(self.total_seconds + another_time.total_seconds)
  end

  def /(num)
    TrackTime.new(self.total_seconds / num)
  end

  def total_seconds
    minutes * 60 + seconds
  end

  class << self
    def zero
      TrackTime.new(0)
    end
  end
end

def read_tracks
  File.open(ARGV[1]).read.split("\n").map do |line|
    if !line.empty?
      trackName, startTime = line.split("--")
      t = Track.new
      t.name = trackName.strip!
      t.start_time = TrackTime.new(startTime.strip!)
      t
    else
      nil
    end
  end.compact
end

def extract_audio(filename, start_time, end_time, output_filename)
  cmd = [
    "ffmpeg",
    "-i #{filename}",
    "-acodec",
    "copy",
    "-ss #{start_time}"
  ]
  if end_time
    duration = end_time - start_time
    cmd << "-t #{duration}"
  end
  cmd << %{"#{output_filename}"}

  `#{cmd.join(" ")}`
end

# MAIN 
if __FILE__ == $PROGRAM_NAME
  if ARGV.length < 2
    puts "Invalid arguments"
    puts "Usage: split.rb [audio_file] [track_list]"
    exit 1
  end

  audio_file_name = ARGV[0]

  file_parts = ARGV[0].split(".")
  extension = file_parts.pop

  current_dir = File.dirname(File.expand_path(__FILE__))
  output_dir = File.join(current_dir, file_parts.join)
  FileUtils.mkdir_p output_dir

  tracks = read_tracks
  tracks.each_with_index do |track, idx|
    next_track = tracks[idx+1]
    output_filename = File.join(output_dir, track.name.gsub("/", " ") + "." + extension)
    extract_audio(audio_file_name, track.start_time, next_track && next_track.start_time || nil, output_filename)
  end
end
