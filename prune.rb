#!/usr/bin/env ruby

require 'rexml/document'

presets = Set.new

File.read("top_100.txt").each_line do |line|
  preset = line.strip
  presets.add(preset.downcase)

  synth_file = "./SYNTHS/Community Pack 1.2/#{preset}.XML"
  kit_file = "./KITS/Community Pack 1.2/#{preset}.XML"
  unless File.exist?(synth_file) || File.exist?(kit_file)
    Warning.warn("#{preset}.XML not found!\n")
  end
end

top_100_samples = Set.new

Dir.glob("./{KITS,SYNTHS}/Community Pack 1.2/*.XML") do |path|
  if presets.include?(File.basename(path, File.extname(path)).downcase)
    puts "IN TOP 100: #{path}"
    
    doc = REXML::Document.new(File.read(path))
    doc.elements.each("//* [@fileName]") do |element|
      path = element.attributes["fileName"]
      puts path.inspect
      if File.exist?(path)
        puts "exists!"
        top_100_samples.add(path)
      end
    end
  else
    puts "DELETING: #{path}"
    File.delete(path)
  end
end

Dir.glob("SAMPLES/**/*") do |path|
  if File.file?(path) && !top_100_samples.include?(path)
    puts "DELETING: #{path}"
    File.delete(path)
  end
end
