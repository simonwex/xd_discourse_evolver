#!/usr/bin/env ruby

require 'pp'
require_relative 'lib/api'

client = get_client

# XD_PLUGINS_CATEGORY_ID = 8

def symbolize_keys!(h)
  h.transform_keys!(&:to_sym)
end

def symbolize_keys(h)
  h.transform_keys(&:to_sym)
end
# http://localhost:3000/c/xd/8/l/latest.json?page=2

xd_plugins_category = symbolize_keys(client.category(XD_PLUGINS_CATEGORY_ID))

if xd_plugins_category[:name] != "XD Plugin Development"
  puts "XD Plugins category name found: \"#{xd_plugins_category[:name]}\". Expected \"XD Plugin Development\""
  exit(0)
end

#about_topics = {33 => 'About the Showcase category'}

categories_to_delete = []

# Find all child categories to xd_plugins_category
client.categories(parent_category_id: XD_PLUGINS_CATEGORY_ID).each do |category|
  symbolize_keys!(category)
  tag_name = category[:name].downcase
  categories_to_delete << category[:id]
  puts "Reorganizing \"#{category[:name]}\" category into posts with additional tag, \"#{tag_name}\" in #{xd_plugins_category[:name]}"
  # http://localhost:3000/c/xd/javascript/11.json
  
  
  # We always retrieve <=30 topics with this call, so make the 
  #   call until there aren't any left
  topics = client.latest_topics(:category => category[:id])
  
  #This is 1 instead of 0 because 
  while topics.size > 1
    topics.each do |topic|
      symbolize_keys!(topic)

      if topic[:category_id] != category[:id]
        puts "Topic, \"#{topic[:title]}\" (#{topic[:id]}) has a mismatched category"
        exit(0)
      end

      tags = topic[:tags]
      tags << tag_name
      tags.uniq!
      pp tags
      puts "Moving topic, \"#{topic[:title]}\" (#{topic[:id]}) #{topic[:category_id]} => #{XD_PLUGINS_CATEGORY_ID} "
      
      client.recategorize_topic_with_new_tags(topic[:id], XD_PLUGINS_CATEGORY_ID, tags, topic[:created_at])
      sleep 1
      client.reset_bump_date(topic[:id])
      sleep 1

    end
    puts
    puts "Getting more topics"
    puts
    topics = client.latest_topics(:category => category[:id])
    
  end
  puts
end
puts
puts "XD Plugins sub categories empty"

categories_to_delete.each do |category_id|
  client.delete_category(category_id)
end

puts
puts "Categories deleted, proceed?"

gets

puts "Creating top-level XD"

xd_top_level = {
  name: 'Adobe XD',
  color: 'ED207B',
  text_color: 'fff'
}

begin
  xd_top_level = C.create_category(xd_top_level)
rescue DiscourseApi::UnprocessableEntity
  puts "Failed to create, enter ID"
  xd_top_level['id'] = gets.to_i
end
symbolize_keys!(xd_top_level)

puts "Created, id: #{xd_top_level[:id]} proceed?"
gets


xd_plugins_category[:parent_category_id] = xd_top_level[:id]
client.update_category(xd_plugins_category)


def safe_create_category(category)
  begin
    return C.create_category(category)
  rescue DiscourseApi::UnprocessableEntity => e
    puts 'Error encountered when creating category: '
    pp category_id
    puts
    puts "Message:"
    puts e.message
    puts
    puts "Proceed?"
    gets
  end
end

xd_cc_api = safe_create_category({
  name: 'XD Cloud Content API',
  color: 'ED207B',
  text_color: 'fff',
  parent_category_id: xd_top_level[:id]
})



fonts = safe_create_category({
  name: 'Adobe Fonts',
  color: 'ccc',
  text_color: 'fff'
})

stock = safe_create_category({
  name: 'Adobe Stock',
  color: '000',
  text_color: 'fff'
})

cc_libraries = safe_create_category({
    name: 'CC Libraries',
    color: '652D90',
    text_color: 'fff'
})

indesign = safe_create_category({
  name: 'InDesign',
  color: 'BF1E2E',
  text_color: 'fff'
})

safe_create_category({
  name: 'InDesign Services API',
  color: indesign['color'],
  text_color: 'fff',
  parent_category_id: indesign['id']
})

safe_create_category({
  name: 'UXP Plugin API',
  color: indesign['color'],
  text_color: 'fff',
  parent_category_id: indesign['id']
})
  
lightroom = safe_create_category({
    name: 'Lightroom',
    color: '25AAE2',
    text_color: 'fff'
})

photoshop = safe_create_category({
  name: 'Photoshop',
  color: '0E76BD',
  text_color: 'fff'
})

uncategorized = safe_create_category({
  name: 'Uncategorized',
  description: "Topics that don't need a category, or don't fit into any other existing category.",
  color: '0088CC',
  text_color: 'fff'
})

puts "Rename UXP Plugin API? (Last step)"

gets
xd_plugins_category[:name] = 'UXP Plugin API'
client.update_category(xd_plugins_category)
