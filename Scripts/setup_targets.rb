#!/usr/bin/env ruby
# setup_targets.rb
# Script to add App Clip and Widget Extension targets to the Xcode project

require 'xcodeproj'

# Open the project
project_path = 'eternal_loop.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "Setting up Xcode project targets..."

# Get the main target
main_target = project.targets.find { |t| t.name == 'eternal_loop' }
raise "Main target not found!" unless main_target

# ================================
# Add App Clip Target
# ================================
puts "Adding App Clip target..."

# Check if App Clip target already exists
app_clip_target = project.targets.find { |t| t.name == 'eternal_loop_Clip' }

unless app_clip_target
  # Create App Clip target
  app_clip_target = project.new_target(:application, 'eternal_loop_Clip', :ios, '17.0')

  # Set as App Clip
  app_clip_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.firstfu.com.eternal-loop.Clip'
    config.build_settings['INFOPLIST_FILE'] = 'eternal_loop_Clip/Info.plist'
    config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'eternal_loop_Clip/eternal_loop_Clip.entitlements'
    config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'

    # App Clip specific settings
    config.build_settings['ENABLE_APP_CLIP'] = 'YES'
  end

  puts "  App Clip target created"
else
  puts "  App Clip target already exists"
end

# Add App Clip as embedded target
embed_phase = main_target.build_phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.name == 'Embed App Clips' }
unless embed_phase
  embed_phase = main_target.new_copy_files_build_phase('Embed App Clips')
  embed_phase.dst_subfolder_spec = '16' # App Clips folder
end

# ================================
# Add Widget Extension Target
# ================================
puts "Adding Widget Extension target..."

widget_target = project.targets.find { |t| t.name == 'EternalLoopWidget' }

unless widget_target
  # Create Widget Extension target
  widget_target = project.new_target(:app_extension, 'EternalLoopWidget', :ios, '17.0')

  widget_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.firstfu.com.eternal-loop.Widget'
    config.build_settings['INFOPLIST_FILE'] = 'eternal_loop/Widget/Info.plist'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'

    # Widget specific settings
    config.build_settings['SKIP_INSTALL'] = 'YES'
    config.build_settings['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = 'WidgetBackground'
  end

  puts "  Widget Extension target created"
else
  puts "  Widget Extension target already exists"
end

# Add Widget as embedded extension
embed_ext_phase = main_target.build_phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.name == 'Embed Foundation Extensions' }
unless embed_ext_phase
  embed_ext_phase = main_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed_ext_phase.dst_subfolder_spec = '13' # PlugIns folder
end

# ================================
# Add App Groups Capability
# ================================
puts "Adding App Groups capability..."

# Note: App Groups need to be added via the project's entitlements file
# This script creates a basic entitlements file if it doesn't exist

main_entitlements_path = 'eternal_loop/eternal_loop.entitlements'
unless File.exist?(main_entitlements_path)
  entitlements_content = <<~ENTITLEMENTS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.application-groups</key>
      <array>
        <string>group.com.eternal-loop</string>
      </array>
    </dict>
    </plist>
  ENTITLEMENTS

  File.write(main_entitlements_path, entitlements_content)
  puts "  Created main app entitlements file"

  # Update build settings
  main_target.build_configurations.each do |config|
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = main_entitlements_path
  end
end

# Save the project
project.save
puts "Project saved successfully!"

puts <<~INSTRUCTIONS

==========================================
NEXT STEPS (Manual Setup Required in Xcode):
==========================================

1. Open eternal_loop.xcodeproj in Xcode

2. For the main app target (eternal_loop):
   - Go to Signing & Capabilities
   - Add "App Groups" capability
   - Add group: "group.com.eternal-loop"

3. For the App Clip target (eternal_loop_Clip):
   - Go to Signing & Capabilities
   - Add "App Groups" capability
   - Add the same group: "group.com.eternal-loop"
   - Add "Associated Domains" capability
   - Add domain: "appclips:eternal-loop.com"

4. For the Widget Extension target (EternalLoopWidget):
   - Go to Signing & Capabilities
   - Add "App Groups" capability
   - Add the same group: "group.com.eternal-loop"

5. Configure code signing for all targets

6. Build and run to verify everything works

==========================================
INSTRUCTIONS
