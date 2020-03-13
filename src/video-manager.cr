require "json"
require "openssl"

SETTINGS_PATH = "#{ENV["HOME"]}/.video-manager-settings.json"

def calculate_checksum(path)
  hash = OpenSSL::Digest.new("sha256")
  hash.update(File.basename(path))
  hash.update(File.size(path).to_s)
  hash.hexdigest
end

struct Settings
  include JSON::Serializable
  property supported_video_extensions : Set(String) = Set.new(["mkv", "mp4", "avi", "wmv", "mov", "mpg", "mpeg", "flv", "swf"])
  property recurse_subdirectories = true
  property num_encoder_threads = 1
  property ffmpeg_options = "ffmpeg -i \"$SRC_PATH\" -c:v libx264 -c:a aac -tune zerolatency -q:a 0 -q:v 0 \"$DEST_PATH\""
  property optimized_hashes : Set(String) = Set(String).new
  property watched_directories : Set(String) = Set(String).new

  def initialize
  end
end

# load settings
settings_exists = File.exists?(SETTINGS_PATH)
settings = settings_exists ? Settings.from_json(File.read(SETTINGS_PATH)) : Settings.new
File.write(SETTINGS_PATH, settings.to_pretty_json) unless settings_exists
if settings.watched_directories.empty?
  puts "watched_directories is empty, nothing to do!"
  puts "please edit #{SETTINGS_PATH} with some valid paths to watch for video files to optimize"
  puts "exiting."
  exit 1
end

# perform initial scan
puts ""
puts "starting scan..."
puts ""
puts "STATUS       SHA256                                                            PATH"
optimize_queue = Array(String).new
num_optimized = 0
settings.watched_directories.each do |dir_path|
  Dir.each_child(dir_path) do |filename|
    path = Path[dir_path].join(filename).to_s
    extension = File.extname(filename.downcase)[1..]
    next unless settings.supported_video_extensions.includes?(extension)
    checksum = calculate_checksum(path)
    already_optimized = settings.optimized_hashes.includes?(checksum)
    puts "[#{already_optimized ? "optimized" : " queuing "}]  #{checksum}  #{path}"
    optimize_queue << path unless already_optimized
    num_optimized += 1 if already_optimized
  end
end
puts ""
puts "detected #{optimize_queue.size} files that need optimization and #{num_optimized} that have already been optimized."
puts ""
puts "entering encoding phase using #{settings.num_encoder_threads} fibers..."
puts ""

# create groups
groups = Array(Array(String)).new
settings.num_encoder_threads.times { groups << Array(String).new }
current = 0
optimize_queue.each do |item|
  groups[current] << item
  current += 1
  current = 0 if current == groups.size
end
