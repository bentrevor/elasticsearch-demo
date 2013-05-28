
contents = [
'This is the content of the first article.',
'This is the content of the second article.',
'This is the content of the third article.',
'Elasticsearch can search by number: 90210.',
'Elasticsearch can also search utf characters: ¨†ƒ (type option-u, option-t, option-f).'
]

puts "Deleting all articles..."
Article.delete_all

unless ENV['COUNT']

  puts "Creating articles..."
  %w[ One Two Three Four Five ].each_with_index do |title, i|
    Article.create :title => title, :content => contents[i]
  end

else

  puts "Creating 10,000 articles..."
  (1..ENV['COUNT'].to_i).each_with_index do |title, i|
    Article.create :title => "Title #{title}", :content => 'Lorem'
    print '.'
  end

end
