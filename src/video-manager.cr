require "json"

SETTINGS_PATH = "#{ENV["HOME"]}/.video-manager-settings.json"

struct Settings
  include JSON::Serializable
  property supported_video_extensions : Set(String) = Set.new(["mkv", "mp4", "avi", "wmv", "mov", "mpg", "mpeg", "flv", "swf"])
  property supported_subtitle_extensions : Set(String) = Set.new(["srt", "sub"])
  property recurse_subdirectories = true
  property num_encoder_threads = 1
  property ffmpeg_options = ""
  property optimized_hashes : Set(String) = Set(String).new

  def initialize
  end
end

settings_exists = File.exists?(SETTINGS_PATH)
settings = settings_exists ? Settings.from_json(File.read(SETTINGS_PATH)) : Settings.new
File.write(SETTINGS_PATH, settings.to_json) unless settings_exists
