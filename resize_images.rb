#
# Resize images from one directory to another
#
# Command line arguments:
#   Script to run to resize
#   Source folder
#   Target folder
#
# ------------------------------------------------------------------------------------------------------
#

script = ARGV[0]
source = ARGV[1]
target = ARGV[2]

# Resize all images if script changed
script_mtime = File.mtime( script)

# Resize source image if no target or target older than source image and script
Dir.entries( source).each do |f|
  next unless f =~ /\.(png|jpg)$/
  source_image = source + '/' + f
  target_image = target + '/' + f

  if (! File.exist?( target_image)) ||
      (File.mtime( source_image) > File.mtime( target_image)) ||
      (script_mtime > File.mtime( target_image))
    raise "Conversion error" if ! system( "csh #{script} #{source_image} #{target_image}")
  end
end

# Delete all images in target folder not in source folder
Dir.entries( target).each do |f|
  next unless f =~ /\.(png|jpg)$/
  source_image = source + '/' + f
  target_image = target + '/' + f

  if (! File.exist?( source_image))
    File.delete( target_image)
  end
end