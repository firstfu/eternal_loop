#!/usr/bin/env ruby
# fix_file_references.rb
# Fixes file references in the Xcode project

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Fix Widget target
widget_target = project.targets.find { |t| t.name == 'EternalLoopWidget' }
if widget_target
  puts "\n--- Fixing EternalLoopWidget ---"

  # Clear existing source files
  widget_target.source_build_phase.files.each do |file|
    puts "Removing: #{file.display_name}"
    file.remove_from_project
  end

  # Find or create the group
  widget_group = project.main_group['EternalLoopWidget']
  if widget_group
    # Remove old file references
    widget_group.children.each { |c| c.remove_from_project }
  else
    widget_group = project.main_group.new_group('EternalLoopWidget', 'EternalLoopWidget')
  end

  # Add the correct file reference
  swift_path = 'EternalLoopWidget/EternalLoopWidget.swift'
  if File.exist?(swift_path)
    file_ref = widget_group.new_reference(swift_path)
    file_ref.set_source_tree('<group>')
    file_ref.set_path('EternalLoopWidget.swift')
    widget_target.source_build_phase.add_file_reference(file_ref)
    puts "Added: #{swift_path}"
  end
end

# Fix App Clip target
clip_target = project.targets.find { |t| t.name == 'eternal_loop_Clip' }
if clip_target
  puts "\n--- Fixing eternal_loop_Clip ---"

  # Clear existing source files
  clip_target.source_build_phase.files.each do |file|
    puts "Removing: #{file.display_name}"
    file.remove_from_project
  end

  # Find or create the group
  clip_group = project.main_group['eternal_loop_Clip']
  if clip_group
    # Remove old file references
    clip_group.children.each { |c| c.remove_from_project }
  else
    clip_group = project.main_group.new_group('eternal_loop_Clip', 'eternal_loop_Clip')
  end

  # Add the correct file references
  ['eternal_loop_ClipApp.swift', 'AppClipContentView.swift'].each do |filename|
    filepath = "eternal_loop_Clip/#{filename}"
    if File.exist?(filepath)
      file_ref = clip_group.new_reference(filepath)
      file_ref.set_source_tree('<group>')
      file_ref.set_path(filename)
      clip_target.source_build_phase.add_file_reference(file_ref)
      puts "Added: #{filepath}"
    end
  end
end

project.save
puts "\n✅ Project saved!"
