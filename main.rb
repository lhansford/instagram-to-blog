require 'date'
require 'fileutils'
require 'json'

require '~/Dropbox/config/scripts/instagram/config.rb'

puts "RUNNING RUBY SCRIPT"

def get_file_date(file_name)
  DateTime.parse(file_name.partition("_")[0]).strftime('%Y-%m-%d')
end

def get_file_name(path)
  path.rpartition('/')[-1]
end

# Extract tags from string and return as comma seperated string
def get_tags(string)
  word_list = string.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(' ')
  word_list
    .select { |word| word.start_with?('#') }
    .map { |word| word[1..-1] }
    .join(', ')
end

def get_index_file(metadata, post_id, file_name)
  title = file_name.rpartition('.')[0]
  content = "---\n"
  post_metadata = metadata.detect {|post| post["urls"].any? {|url| url.include?(post_id)}}
  description = if post_metadata['edge_media_to_caption']['edges'].any?
    then post_metadata['edge_media_to_caption']['edges'][0]['node']['text']
    else "" end
  # Dont use thumbnail if post is an album (blog has no album functionality, so thumbnails won't make sense)
  thumbnail = if post_metadata["urls"].length > 1 then "/photos/#{title}/#{file_name}" else thumbnail(post_metadata) end
  content += "title: #{title}"
  content += "\nfile_name: #{file_name}"
  content += "\ndescription: #{description}"
  content += "\nlink: https://www.instagram.com/p/#{post_metadata['shortcode']}"
  content += "\nthumbnail: #{thumbnail}"
  content += "\ntags: #{(post_metadata['tags'] || []).join(', ')}"
  content += "\nauthor: luke"
  content += "\ndate: #{DateTime.strptime(post_metadata['taken_at_timestamp'].to_s, '%s').strftime('%Y-%m-%d %H:%M')}"
  if file_name.rpartition('.')[-1] === 'jpg'
    content + "\ntemplate: photo.hbs\n---"
  else
    content + "\ntemplate: video.hbs\n---"
  end
end

def thumbnail(post_metadata)
  return post_metadata['thumbnail_src'] if post_metadata['thumbnail_resources'].nil?

  post_metadata['thumbnail_resources'].first(2).last['src']
end

def copy_files_and_create_index(metadata, new_dir, file_path, file_name)
  FileUtils.cp(file_path, new_dir + '/' + file_name)
  out_file = File.new(new_dir + '/index.md', 'w')
  out_file.puts(get_index_file(metadata, file_name.partition("_")[-1], file_name))
  out_file.close
end

metadata = JSON.parse(File.read(METADATA_FILE))
posts = {}

Dir[INBOX_PATH + '/*'].each do |file_path|
  if file_path.end_with?(".jpg") or file_path.end_with?(".mp4")
    file_name = get_file_name(file_path)
    puts 'Processing ' + file_path
    formatted_date = get_file_date(file_name)
    posts[file_name] = {
      'date' => formatted_date,
      'file_path' => file_path,
    }
  end
end

## Copy to blog
posts.each do |file_name, value|
  new_dir = POSTS_DIR + file_name.partition(".")[0]
  unless (Dir.exist?(new_dir))
    Dir.mkdir(new_dir)
    copy_files_and_create_index(metadata, new_dir, value['file_path'], file_name)
    ## Move image to dropbox folder
    FileUtils.mv(value['file_path'], PHOTOS_DIR + file_name)
  end
end
