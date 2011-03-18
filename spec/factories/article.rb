require "factory_girl"

Factory.define(:article) do |f|
  f.title { Faker::Lorem.sentence }
  f.body { Faker::Lorem.paragraphs.join("\n\n") }
end

