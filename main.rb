require 'date'
require 'fileutils'
require 'json'

require '~/Dropbox/config/scripts/instagram/config.rb'

puts "RUNNING RUBY SCRIPT"

def parse_text_file(file_path)
  File.open(file_path, "r") do |f|
    f.each_line do |line|
      return line.split("|") # should only be one line
    end
  end
end

def get_index_file(post_id, post_hash)
  content = "---\n"

  shortcode, date, post_content =  parse_text_file(post_hash[:text])

  image_paths = post_hash[:images].map do |image_path|
    _, _, image_file_name = image_path.rpartition("/")

    "/photos/#{post_id}/#{image_file_name}"
  end

  thumbnail = "/photos/#{post_id}/#{image_paths[0]}"

  content += "title: #{post_id}"
  content += "\ndescription: #{post_content}"
  content += "\nlink: https://www.instagram.com/p/#{shortcode}"
  content += "\nthumbnail: #{thumbnail}"
  content += "\nauthor: luke"
  content += "\ndate: #{date}"
  content += "\nimages: #{image_paths.join(',')}"
  if post_hash[:video].nil?
    content + "\ntemplate: photo.hbs\n---"
  else
    content + "\ntemplate: video.hbs\n---"
  end
end

def copy_files_and_create_index(post_dir, post_id, post_hash)
  FileUtils.cp(post_hash[:video], post_dir + '/') unless post_hash[:video].nil?
  FileUtils.cp(post_hash[:text], post_dir + '/')
  post_hash[:images].each do |file_path|
    FileUtils.cp(file_path, post_dir + '/')
  end

  out_file = File.new(post_dir + '/index.md', 'w')
  out_file.puts(get_index_file(post_id, post_hash))
  out_file.close

  puts "Created post #{post_id}"
end

def collect_files
  files = {}
  Dir[PHOTOS_DIR + '/*'].each do |file_path|
    _, _, filename = file_path.rpartition('/')

    next if filename == USER_FILE

    filename, _, extension = filename.rpartition('.')
    name, _, last = filename.rpartition('_') # For when a post has multiple images
    name = last if name.empty?
    files[name] = { video: nil, images: [], text: nil } if files[name].nil?

    if extension == 'txt'
      files[name][:text] = file_path
    elsif extension == 'mp4'
      files[name][:video] = file_path
    elsif extension == 'jpg'
      files[name][:images] << file_path
    end
  end

  return files
end

## Copy to blog
collect_files().each do |key, val|
  new_dir = POSTS_DIR + key
  unless (Dir.exist?(new_dir))
    Dir.mkdir(new_dir)
    copy_files_and_create_index(new_dir, key, val)
  end
end
