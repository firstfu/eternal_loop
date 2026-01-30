#!/usr/bin/env ruby
# fix_paths.rb
# Fixes file paths in the Xcode project

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'
WIDGET_NAME = 'EternalLoopWidget'
APP_CLIP_NAME = 'eternal_loop_Clip'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Fix Widget target source files
puts "\n--- Fixing Widget target ---"
widget_target = project.targets.find { |t| t.name == WIDGET_NAME }
if widget_target
  # Clear source files
  widget_target.source_build_phase.files.each do |file|
    file.remove_from_project
  end

  # Find the group
  widget_group = project.main_group[WIDGET_NAME]
  widget_group&.clear

  # Add file with correct path
  file_ref = project.new_file("#{WIDGET_NAME}/EternalLoopWidget.swift")
  file_ref.move(widget_group) if widget_group
  widget_target.source_build_phase.add_file_reference(file_ref)
  puts "Fixed: EternalLoopWidget.swift"
end

# Fix App Clip target source files
puts "\n--- Fixing App Clip target ---"
clip_target = project.targets.find { |t| t.name == APP_CLIP_NAME }
if clip_target
  # Clear source files
  clip_target.source_build_phase.files.each do |file|
    file.remove_from_project
  end

  # Clear resources
  clip_target.resources_build_phase.files.each do |file|
    file.remove_from_project
  end

  # Find the group
  clip_group = project.main_group[APP_CLIP_NAME]
  clip_group&.clear

  # Add files with correct paths
  ['eternal_loop_ClipApp.swift', 'AppClipContentView.swift'].each do |filename|
    file_ref = project.new_file("#{APP_CLIP_NAME}/#{filename}")
    file_ref.move(clip_group) if clip_group
    clip_target.source_build_phase.add_file_reference(file_ref)
    puts "Fixed: #{filename}"
  end

  # Add Assets
  assets_ref = project.new_file("#{APP_CLIP_NAME}/Assets.xcassets")
  assets_ref.move(clip_group) if clip_group
  clip_target.resources_build_phase.add_file_reference(assets_ref)
  puts "Fixed: Assets.xcassets"
end

project.save
puts "\n✅ Paths fixed!"
