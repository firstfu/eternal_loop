#!/usr/bin/env ruby
# recreate_targets.rb
# Completely recreates Widget and App Clip targets with correct settings

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'
WIDGET_NAME = 'EternalLoopWidget'
APP_CLIP_NAME = 'eternal_loop_Clip'
BUNDLE_ID_PREFIX = 'com.firstfu.com.eternal-loop'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

main_target = project.targets.find { |t| t.name == 'eternal_loop' }

# Remove broken dependencies
puts "\n--- Cleaning up dependencies ---"
deps_to_remove = main_target.dependencies.select { |dep| dep.target.nil? }
deps_to_remove.each do |dep|
  puts "Removing broken dependency"
  dep.remove_from_project
end

# Remove existing Widget and App Clip targets
puts "\n--- Removing existing targets ---"
targets_to_remove = project.targets.select { |t| [WIDGET_NAME, APP_CLIP_NAME].include?(t.name) }
targets_to_remove.each do |target|
  # First remove dependencies to this target
  main_target.dependencies.each do |dep|
    if dep.target&.name == target.name
      puts "Removing dependency to: #{target.name}"
      dep.remove_from_project
    end
  end
  puts "Removing target: #{target.name}"
  target.remove_from_project
end

# Remove existing groups
[WIDGET_NAME, APP_CLIP_NAME].each do |name|
  group = project.main_group[name]
  if group
    puts "Removing group: #{name}"
    group.remove_from_project
  end
end

# Remove embed phases from main target
phases_to_remove = main_target.build_phases.select do |phase|
  phase.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) &&
    ['Embed App Clips', 'Embed Foundation Extensions'].include?(phase.name)
end
phases_to_remove.each do |phase|
  puts "Removing build phase: #{phase.name}"
  phase.remove_from_project
end

project.save
puts "\n✅ Cleaned up project"

# Now recreate targets
puts "\n--- Creating Widget Extension Target ---"

# Create Widget target
widget_target = project.new_target(:app_extension, WIDGET_NAME, :ios, '17.0')

widget_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID_PREFIX}.Widget"
  config.build_settings['PRODUCT_NAME'] = WIDGET_NAME
  config.build_settings['INFOPLIST_FILE'] = "#{WIDGET_NAME}/Info.plist"
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "#{WIDGET_NAME}/EternalLoopWidget.entitlements"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
end

# Create Widget group and add file
widget_group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)
widget_file = widget_group.new_file("#{WIDGET_NAME}/EternalLoopWidget.swift")
widget_target.source_build_phase.add_file_reference(widget_file)
puts "Created Widget target with source file"

puts "\n--- Creating App Clip Target ---"

# Create App Clip target
clip_target = project.new_target(:application, APP_CLIP_NAME, :ios, '17.0')

clip_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID_PREFIX}.Clip"
  config.build_settings['PRODUCT_NAME'] = APP_CLIP_NAME
  config.build_settings['INFOPLIST_FILE'] = "#{APP_CLIP_NAME}/Info.plist"
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "#{APP_CLIP_NAME}/eternal_loop_Clip.entitlements"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end

# Create App Clip group and add files
clip_group = project.main_group.new_group(APP_CLIP_NAME, APP_CLIP_NAME)
['eternal_loop_ClipApp.swift', 'AppClipContentView.swift'].each do |filename|
  file = clip_group.new_file("#{APP_CLIP_NAME}/#{filename}")
  clip_target.source_build_phase.add_file_reference(file)
  puts "Added: #{filename}"
end

# Add Assets.xcassets
assets_path = "#{APP_CLIP_NAME}/Assets.xcassets"
if File.exist?(assets_path)
  assets_ref = clip_group.new_file(assets_path)
  clip_target.resources_build_phase.add_file_reference(assets_ref)
  puts "Added: Assets.xcassets"
end

project.save
puts "\nTargets created, adding build phases..."

# Now add dependencies and embed phases
puts "\n--- Adding embed phases ---"

# Add embed extension phase
embed_ext = main_target.new_copy_files_build_phase('Embed Foundation Extensions')
embed_ext.dst_subfolder_spec = '13'  # PlugIns
puts "Added: Embed Foundation Extensions"

# Add embed app clips phase
embed_clips = main_target.new_copy_files_build_phase('Embed App Clips')
embed_clips.dst_subfolder_spec = '16'  # App Clips
puts "Added: Embed App Clips"

project.save
puts "\n--- Adding dependencies ---"

# Add dependencies safely
begin
  main_target.add_dependency(widget_target)
  puts "Added dependency: eternal_loop -> #{WIDGET_NAME}"
rescue => e
  puts "Warning: Could not add widget dependency: #{e.message}"
end

begin
  main_target.add_dependency(clip_target)
  puts "Added dependency: eternal_loop -> #{APP_CLIP_NAME}"
rescue => e
  puts "Warning: Could not add clip dependency: #{e.message}"
end

project.save
puts "\n✅ Project saved successfully!"

puts "\n" + "=" * 50
puts "TARGETS CREATED:"
puts "=" * 50
project.targets.each do |t|
  puts "  - #{t.name}"
end
