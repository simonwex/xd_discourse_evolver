require 'discourse_api'

module DiscourseApi
  module API
    module Topics
      def rename_topic(topic_id, title)
        put("/t/#{topic_id}.json", topic_id: topic_id, title: title)
      end

      def recategorize_topic_with_new_tags(topic_id, category_id, tags)
        put("/t/#{topic_id}.json", topic_id: topic_id, category_id: category_id, tags: tags)
      end
    end
  end
  module API
    module Categories
      def category_topics(category_slug)
        # http://localhost:3000/c/xd/javascript/11.json

        # response = get("/c/#{category_slug}/l/new.json")
        # response[:body]['topic_list']['topics']
      end
    end
  end
end




def self.get_client
  client = DiscourseApi::Client.new("http://localhost:3000")
  client.api_key = "bd0dc7cf6fe74e28b2536472c2037b4f9c84f57745146abd59428cf6af97f431"
  client.api_username = 'simon'

  return client
end
C = get_client
XD_PLUGINS_CATEGORY_ID = 8
