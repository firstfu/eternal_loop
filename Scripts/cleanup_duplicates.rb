#!/usr/bin/env ruby
# cleanup_duplicates.rb
# Removes duplicate targets, products, and file references

require 'xcodeproj'

PROJECT_PATH = 'eternal_loop.xcodeproj'

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# Find duplicate targets
puts "\n--- Checking for duplicate targets ---"
target_names = project.targets.map(&:name)
duplicates = target_names.select { |name| target_names.count(name) > 1 }.uniq

if duplicates.empty?
  puts "No duplicate targets found"
else
  puts "Found duplicate targets: #{duplicates.join(', ')}"

  duplicates.each do |target_name|
    targets = project.targets.select { |t| t.name == target_name }
    # Keep the first, remove others
    targets[1..-1].each do |dup_target|
      puts "Removing duplicate target: #{dup_target.name} (#{dup_target.uuid})"
      dup_target.remove_from_project
    end
  end
end

# Clean up orphaned product references in Products group
puts "\n--- Cleaning up Products group ---"
products_group = project.main_group['Products']
if products_group
  valid_product_names = project.targets.map { |t| "#{t.product_name || t.name}.#{t.product_type.split('.').last}" rescue t.name }

  products_group.children.each do |product_ref|
    # Check if this product belongs to an active target
    has_target = project.targets.any? { |t| t.product_reference&.uuid == product_ref.uuid }
    unless has_target
      puts "Removing orphaned product: #{product_ref.display_name}"
      product_ref.remove_from_project
    end
  end
end

# Remove duplicate file references in source build phases
puts "\n--- Cleaning up duplicate source files ---"
project.targets.each do |target|
  next unless target.respond_to?(:source_build_phase)

  seen_files = {}
  files_to_remove = []

  target.source_build_phase.files.each do |build_file|
    file_name = build_file.file_ref&.path rescue nil
    next unless file_name

    if seen_files[file_name]
      files_to_remove << build_file
    else
      seen_files[file_name] = true
    end
  end

  files_to_remove.each do |file|
    puts "Removing duplicate from #{target.name}: #{file.file_ref&.path}"
    file.remove_from_project
  end
end

project.save
puts "\n✅ Cleanup complete!"

# Final verification
puts "\n--- Final target list ---"
project.targets.each do |t|
  puts "  - #{t.name} (#{t.product_type})"
end
