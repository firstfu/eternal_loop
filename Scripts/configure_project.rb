#!/usr/bin/env ruby
# configure_project.rb
# Adds Widget Extension and App Clip targets to the Xcode project

require 'xcodeproj'
require 'fileutils'

PROJECT_PATH = 'eternal_loop.xcodeproj'
WIDGET_NAME = 'EternalLoopWidget'
APP_CLIP_NAME = 'eternal_loop_Clip'
BUNDLE_ID_PREFIX = 'com.firstfu.com.eternal-loop'
APP_GROUP = 'group.com.eternal-loop'

def main
  puts "Opening project: #{PROJECT_PATH}"
  project = Xcodeproj::Project.open(PROJECT_PATH)

  main_target = project.targets.find { |t| t.name == 'eternal_loop' }
  raise "Main target 'eternal_loop' not found!" unless main_target

  # Add Widget Extension
  widget_target = add_widget_extension(project, main_target)

  # Add App Clip (check if it exists first)
  app_clip_target = add_app_clip(project, main_target)

  # Save the project
  project.save
  puts "\n✅ Project saved successfully!"

  puts "\n" + "=" * 50
  puts "NEXT STEPS:"
  puts "=" * 50
  puts "1. Open Xcode and verify the targets"
  puts "2. Configure signing for each target"
  puts "3. Build and run to test"
end

def add_widget_extension(project, main_target)
  puts "\n--- Adding Widget Extension ---"

  # Check if widget target exists
  existing = project.targets.find { |t| t.name == WIDGET_NAME }
  if existing
    puts "Widget target '#{WIDGET_NAME}' already exists, skipping creation"
    return existing
  end

  # Create the widget extension target
  widget_target = project.new_target(:app_extension, WIDGET_NAME, :ios, '17.0')
  puts "Created widget target: #{WIDGET_NAME}"

  # Configure build settings
  widget_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID_PREFIX}.Widget"
    config.build_settings['INFOPLIST_FILE'] = "#{WIDGET_NAME}/Info.plist"
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "#{WIDGET_NAME}/EternalLoopWidget.entitlements"
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
    config.build_settings['MARKETING_VERSION'] = '1.0'
    config.build_settings['SKIP_INSTALL'] = 'YES'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
    config.build_settings['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = 'WidgetBackground'
  end

  # Add source files group
  widget_group = project.main_group.find_subpath(WIDGET_NAME, false)
  unless widget_group
    widget_group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)
    puts "Created group: #{WIDGET_NAME}"
  end

  # Add Swift file to target
  swift_file_path = "#{WIDGET_NAME}/EternalLoopWidget.swift"
  if File.exist?(swift_file_path)
    file_ref = widget_group.new_file(swift_file_path)
    widget_target.source_build_phase.add_file_reference(file_ref)
    puts "Added source file: #{swift_file_path}"
  end

  # Add to main target's embed extensions phase
  embed_phase = main_target.build_phases.find { |p|
    p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.name == 'Embed Foundation Extensions'
  }
  unless embed_phase
    embed_phase = main_target.new_copy_files_build_phase('Embed Foundation Extensions')
    embed_phase.dst_subfolder_spec = '13' # PlugIns folder
    puts "Created 'Embed Foundation Extensions' build phase"
  end

  # Add dependency
  main_target.add_dependency(widget_target)
  puts "Added dependency: #{main_target.name} -> #{WIDGET_NAME}"

  widget_target
end

def add_app_clip(project, main_target)
  puts "\n--- Adding App Clip ---"

  # Check if app clip target exists
  existing = project.targets.find { |t| t.name == APP_CLIP_NAME }
  if existing
    puts "App Clip target '#{APP_CLIP_NAME}' already exists, skipping creation"
    return existing
  end

  # Create the app clip target
  app_clip_target = project.new_target(:application, APP_CLIP_NAME, :ios, '17.0')
  puts "Created App Clip target: #{APP_CLIP_NAME}"

  # Configure build settings
  app_clip_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID_PREFIX}.Clip"
    config.build_settings['INFOPLIST_FILE'] = "#{APP_CLIP_NAME}/Info.plist"
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "#{APP_CLIP_NAME}/eternal_loop_Clip.entitlements"
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
    config.build_settings['MARKETING_VERSION'] = '1.0'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'

    # App Clip specific
    config.build_settings['ENABLE_ON_DEMAND_RESOURCES'] = 'YES'
  end

  # Add source files group
  clip_group = project.main_group.find_subpath(APP_CLIP_NAME, false)
  unless clip_group
    clip_group = project.main_group.new_group(APP_CLIP_NAME, APP_CLIP_NAME)
    puts "Created group: #{APP_CLIP_NAME}"
  end

  # Add Swift files to target
  Dir.glob("#{APP_CLIP_NAME}/*.swift").each do |swift_file|
    file_ref = clip_group.new_file(swift_file)
    app_clip_target.source_build_phase.add_file_reference(file_ref)
    puts "Added source file: #{swift_file}"
  end

  # Add to main target's embed app clips phase
  embed_phase = main_target.build_phases.find { |p|
    p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.name == 'Embed App Clips'
  }
  unless embed_phase
    embed_phase = main_target.new_copy_files_build_phase('Embed App Clips')
    embed_phase.dst_subfolder_spec = '16' # App Clips folder
    puts "Created 'Embed App Clips' build phase"
  end

  # Add dependency
  main_target.add_dependency(app_clip_target)
  puts "Added dependency: #{main_target.name} -> #{APP_CLIP_NAME}"

  app_clip_target
end

# Run the script
main
