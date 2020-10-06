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

about_topics = {33 => 'About the Showcase category'}

# Find all child categories to xd_plugins_category
client.categories(parent_category_id: XD_PLUGINS_CATEGORY_ID).each do |category|
  symbolize_keys!(category)
  tag_name = category[:name].downcase
  puts "Reorganizing \"#{category[:name]}\" category into posts with additional tag, \"#{tag_name}\" in #{xd_plugins_category[:name]}"
  # http://localhost:3000/c/xd/javascript/11.json
  
  
  # We always retrieve <=30 topics with this call, so make the 
  #   call until there aren't any left
  topics = client.latest_topics(:category => category[:id])
  
  #This is 1 instead of 0 because 
  while topics.size > 1
    topics.each do |topic|
      symbolize_keys!(topic)

      # The last topic in the category, is also one we don't want to move.
      # These are collected above and simply deleted along with the category
      if about_topics.has_key?(topic[:id])
        if topic[:title] == about_topics[topic[:id]]
          puts "Found the last topic, \"#{topics[:title]}\""
          #client.delete_topic(topic[:id])
        else
          puts "Error, thought this was the last topic, but mismatched name: \"#{topics[:title]}\" (Expected, \"#{about_topics[topic[:id]]}\") "
          gets
        end
      else
        if topic[:category_id] != category[:id]
          puts "Topic, \"#{topic[:title]}\" (#{topic[:id]}) has a mismatched category"
          exit(0)
        end

        tags = topic[:tags]
        tags << tag_name
        tags.uniq!
        pp tags
        puts "Moving topic, \"#{topic[:title]}\" (#{topic[:id]}) #{topic[:category_id]} => #{XD_PLUGINS_CATEGORY_ID} "
        
        client.recategorize_topic_with_new_tags(topic[:id], XD_PLUGINS_CATEGORY_ID, tags)
        sleep 1
      end

    end
    puts
    puts "Getting more topics"
    puts
    topics = client.latest_topics(:category => category[:id])
    
  end
  puts
end

puts "XD Plugins sub categories empty, proceed?"
gets

recategorize_topic(topic_id, category_id)


puts "Creating top-level XD"
xd_top_level = client.create_category({
  name: 'Adobe XD',
  color: 'ED207B',
  text_color: 'fff'
})
symbolize_keys!(xd_top_level)

puts "Created, id: #{xd_top_level[:id]}"
gets


exit(0)

xd_plugins_category[:parent_category_id] = xd_top_level[:id]
client.update_category(xd_plugins_category)



client.recategorize_topic(topic_id: 108, category_id: 5)

fonts = client.create_category({
    name: 'Adobe Fonts',
    color: 'ccc',
    text_color: 'fff'
  }
)

stock = client.create_category({
  name: 'Adobe Stock',
  color: '000',
  text_color: 'fff'
})

cc_libraries = client.create_category({
    name: 'CC Libraries',
    color: '652D90',
    text_color: 'fff'
})

indesign = client.create_category({
  name: 'InDesign',
  color: 'BF1E2E',
  text_color: 'fff'
})
  
lightroom = client.create_category({
    name: 'Lightroom',
    color: '25AAE2',
    text_color: 'fff'
})

photoshop = client.create_category({
  name: 'Photoshop',
  color: '0E76BD',
  text_color: 'fff'
})

uncategorized = client.create_category({
  name: 'Uncategorized',
  description: "Topics that don't need a category, or don't fit into any other existing category.",
  color: '0088CC',
  text_color: 'fff'
})
