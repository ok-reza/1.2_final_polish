#!/usr/bin/env ruby

require 'rexml/document'

SUBFOLDER = "Community Pack 1.2"

def read_top_100_preset_names
  top_100_presets = Set.new
  File.read("top_100.txt").each_line do |line|
    preset = line.strip
    top_100_presets.add(preset.downcase)

    synth_file = "./SYNTHS/Community Pack 1.2/#{preset}.XML"
    kit_file = "./KITS/Community Pack 1.2/#{preset}.XML"
    unless File.exist?(synth_file) || File.exist?(kit_file)
      Warning.warn("#{preset}.XML not found!\n")
    end
  end
  return top_100_presets
end

def find_preset_files_for(preset_names, positive=true)
  preset_files = Set.new
  Dir.glob("{KITS,SYNTHS}/#{SUBFOLDER}/*.XML") do |path|
    path_is_included = preset_names.include?(File.basename(path, File.extname(path)).downcase)
    if (positive && path_is_included) || (!positive && !path_is_included)
      preset_files.add(path)
    end
  end
  preset_files
end

def find_sample_files_used_by(preset_path)
  sample_files = Set.new
  doc = REXML::Document.new(File.read(preset_path))
  doc.elements.each("//* [@fileName]") do |element|
    sample_path = element.attributes["fileName"]
    if File.exist?(sample_path)
      sample_files.add(sample_path)
    end
  end
  sample_files
end

def remove_files_besides!(files, actually_remove=true)
  Dir.glob("{KITS,SYNTHS,SAMPLES}/#{SUBFOLDER}/**/*") do |path|
    if File.file?(path) && !files.include?(path)
      puts "DELETING FILE: #{path}"
      File.delete(path) if actually_remove
    end
  end
end

def remove_empty_folders!(actually_remove=true)
  Dir.glob("{KITS,SYNTHS,SAMPLES}/#{SUBFOLDER}/**/*") do |path|
    if File.directory?(path) && Dir.empty?(path)
      puts "REMOVING EMPTY DIRECTORY: #{path}"
      Dir.delete(path) if actually_remove
    end
  end
end

# top_100_preset_names = read_top_100_preset_names

# b_sides_preset_files = find_preset_files_for(top_100_preset_names, false)

# b_sides_sample_files = b_sides_preset_files.reduce(Set.new) do |all, preset_path|
#   all.merge(find_sample_files_used_by(preset_path))
# end

# all_files_to_keep = b_sides_preset_files.union(b_sides_sample_files)


# remove_files_besides!(all_files_to_keep)

# remove_empty_folders!
