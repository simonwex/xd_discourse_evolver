# Rename XD Dev forums into CC Dev forums

### Gotchas

#### Force SSL 

When restoring a production db, if running locally, all login sessions will fail. This is because in production SiteSetting.force_https is true

To fix:

```ruby
bin/rails c
SiteSetting.force_https = false
```


## The program:
require 'discourse_api'
client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = "dadd24fdb7cf37d74f4ecd82b8b8642d5a4063708b137bc3a0f3b9baa0147e58"
client.api_username = 'simon'


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

xd = client.create_category({
  name: 'Adobe XD',
  color: 'ED207B',
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
  text_color: 'fff
})

uncategorized = client.create_category({
  name: 'Uncategorized',
  description: "Topics that don't need a category, or don't fit into any other existing category.",
  color: '0088CC',
  text_color: 'fff'
})
