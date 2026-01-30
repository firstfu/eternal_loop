#!/usr/bin/env ruby
# fix_file_paths_correct.rb
# Fixes the doubled file paths in Xcode project by setting correct relative paths

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Fix Widget group files
puts "\n--- Fixing EternalLoopWidget file paths ---"
widget_group = project.main_group.find_subpath('EternalLoopWidget', false)
if widget_group
  widget_group.children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
      old_path = child.path
      # Extract just the filename
      filename = File.basename(child.path)
      if child.path != filename
        child.path = filename
        puts "Fixed: #{old_path} -> #{filename}"
      end
    end
  end
else
  puts "Warning: EternalLoopWidget group not found"
end

# Fix App Clip group files
puts "\n--- Fixing eternal_loop_Clip file paths ---"
clip_group = project.main_group.find_subpath('eternal_loop_Clip', false)
if clip_group
  clip_group.children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
      old_path = child.path
      # Extract just the filename (or relative path within group)
      filename = File.basename(child.path)
      # Keep Assets.xcassets as is since it's a folder reference
      if child.path.include?('/') && !child.path.include?('xcassets')
        child.path = filename
        puts "Fixed: #{old_path} -> #{filename}"
      elsif child.path.include?('eternal_loop_Clip/')
        new_path = child.path.sub('eternal_loop_Clip/', '')
        child.path = new_path
        puts "Fixed: #{old_path} -> #{new_path}"
      end
    end
  end
else
  puts "Warning: eternal_loop_Clip group not found"
end

project.save
puts "\n✅ File paths fixed!"

# Verify the fix
puts "\n--- Verification ---"
puts "EternalLoopWidget group files:"
widget_group = project.main_group.find_subpath('EternalLoopWidget', false)
widget_group&.children&.each do |child|
  puts "  - #{child.display_name}: path=#{child.path}, sourceTree=#{child.source_tree}"
end

puts "\neternal_loop_Clip group files:"
clip_group = project.main_group.find_subpath('eternal_loop_Clip', false)
clip_group&.children&.each do |child|
  puts "  - #{child.display_name}: path=#{child.path}, sourceTree=#{child.source_tree}"
end
