require "json"

VALID_VIDEO_EXTENSIONS = Set.new(["mkv", "mp4", "avi", "wmv", "mov", "mpg", "mpeg", "flv", "swf"])

abstract class VideoFile
  property path : String
  property encoding_started_at : Time | Nil
  property encoding_finished_at : Time | Nil
  property encoding_options : String
  property sha256 : String

  abstract def refresh
  abstract def exists? : Bool
  abstract def name : String
  abstract def size : UInt64
  abstract def created_at : Time
  abstract def modified_at : Time
  abstract def copy_to_local(local_path : String)
  abstract def replace_with_local(src_path : String)
end

class LocalVideoFile < VideoFile

end

abstract class VideoDirectory
  property path : String

  abstract def files : Array(VideoFile)
end

class LocalVideoDirectory < VideoDirectory
  def initialize(@path)
    @files = Array(LocalVideoFile).new
    Dir.children(@path).each do |filename|
      next unless 
    end
  end

  def files

  end
end

class SambaVideoDirectory < VideoDirectory

end
