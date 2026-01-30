#!/usr/bin/env ruby
# fix_product_names.rb
# Fixes PRODUCT_NAME settings for Widget and App Clip targets

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Fix Widget target
widget_target = project.targets.find { |t| t.name == 'EternalLoopWidget' }
if widget_target
  puts "\nFixing EternalLoopWidget target..."
  widget_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_NAME'] = 'EternalLoopWidget'
    config.build_settings['PRODUCT_MODULE_NAME'] = 'EternalLoopWidget'
    puts "  #{config.name}: PRODUCT_NAME = EternalLoopWidget"
  end
end

# Fix App Clip target
clip_target = project.targets.find { |t| t.name == 'eternal_loop_Clip' }
if clip_target
  puts "\nFixing eternal_loop_Clip target..."
  clip_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_NAME'] = 'eternal_loop_Clip'
    config.build_settings['PRODUCT_MODULE_NAME'] = 'eternal_loop_Clip'
    puts "  #{config.name}: PRODUCT_NAME = eternal_loop_Clip"
  end
end

project.save
puts "\n✅ Project saved!"
