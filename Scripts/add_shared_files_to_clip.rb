#!/usr/bin/env ruby
# add_shared_files_to_clip.rb
# Adds shared source files to App Clip target so it can access shared types

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'

# Files needed by App Clip (relative to project root)
SHARED_FILES = [
  # Design System
  'eternal_loop/Core/DesignSystem/Colors.swift',
  'eternal_loop/Core/DesignSystem/Spacing.swift',
  'eternal_loop/Core/DesignSystem/Typography.swift',

  # Models
  'eternal_loop/Core/Models/CeremonyState.swift',
  'eternal_loop/Core/Models/CeremonyMessage.swift',
  'eternal_loop/Core/Models/RingType.swift',

  # Connectivity
  'eternal_loop/Core/Connectivity/MultipeerManager.swift',
  'eternal_loop/Core/Connectivity/NearbyInteractionManager.swift',

  # Haptics
  'eternal_loop/Core/Haptics/HeartbeatHaptics.swift',

  # Views
  'eternal_loop/Features/Ceremony/GuestCeremonyView.swift',
  'eternal_loop/Features/AR/ARRingView.swift',
  'eternal_loop/Features/Ceremony/RingTransferAnimation.swift',
  'eternal_loop/Features/Components/PrimaryButton.swift',

  # AR
  'eternal_loop/Core/AR/HandTrackingManager.swift',

  # Animation
  'eternal_loop/Core/Animation/AnimationEffects.swift',

  # Utils
  'eternal_loop/Core/Utils/ModelLoader.swift',
]

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Find App Clip target
clip_target = project.targets.find { |t| t.name == 'eternal_loop_Clip' }
unless clip_target
  puts "Error: eternal_loop_Clip target not found"
  exit 1
end

puts "\n--- Adding shared files to App Clip target ---"

SHARED_FILES.each do |file_path|
  unless File.exist?(file_path)
    puts "Warning: File not found: #{file_path}"
    next
  end

  # Check if file is already in the target's sources
  already_added = clip_target.source_build_phase.files.any? do |build_file|
    build_file.file_ref&.path&.include?(File.basename(file_path))
  end

  if already_added
    puts "Skipping (already added): #{file_path}"
    next
  end

  # Find the file reference in the project
  file_ref = project.files.find { |f| f.path == file_path || f.real_path.to_s.end_with?(file_path) }

  if file_ref
    # Add existing file reference to App Clip target
    clip_target.source_build_phase.add_file_reference(file_ref)
    puts "Added: #{file_path}"
  else
    # Create new file reference and add to target
    file_ref = project.new_file(file_path)
    clip_target.source_build_phase.add_file_reference(file_ref)
    puts "Created and added: #{file_path}"
  end
end

project.save
puts "\n✅ Shared files added to App Clip target!"

# Verify
puts "\n--- App Clip source files ---"
clip_target.source_build_phase.files.each do |file|
  puts "  - #{file.display_name}"
end
