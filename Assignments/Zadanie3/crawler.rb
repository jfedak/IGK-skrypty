require 'nokogiri'
require 'open-uri'
require 'sequel'
require 'uri'
require 'json'

DB = Sequel.sqlite('allegro.db')

DB.create_table? :offers do
  primary_key :id
  String :title
  String :price
  Text :details
  String :seller
  String :location
  String :url
end

offers_table = DB[:offers]

print "Please enter keywords (separated by spaces): "
input = gets.chomp.strip
keywords = input.split(/\s+/)

encoded_text = URI.encode_www_form_component(input).gsub('+', '%20')
url = "https://allegrolokalnie.pl/oferty/q/#{encoded_text}?zrodlo=lokalnie"

puts "url: #{url}"


begin
  html_content = URI.open(url).read 
  doc = Nokogiri::HTML(html_content, nil, 'UTF-8')
  offers = doc.css('article')

  offers.each_with_index do |offer, index|
    title_node = offer.at_css('h3.mlc-itembox__title')
    title = title_node ? title_node.text.strip : "No title"

    link_node = offer.at_css('a.mlc-card')
    raw_link = link_node ? link_node['href'] : nil
    link = raw_link ? "https://allegrolokalnie.pl#{raw_link}" : "No link"
    
    price_node = offer.at_css('.ml-offer-price')
    price = price_node ? price_node.text.strip.gsub(/\s+/, ' ') : "No price"

    next if title == "No title" || price == "No price" || link == "No link"

    begin
      subpage_html_content = URI.open(link).read
      subpage_doc = Nokogiri::HTML(subpage_html_content, nil, 'UTF-8')

      paragraphs = subpage_doc.css('div.mlc-offer__description p.desc-p')
      if paragraphs.any?
        details = paragraphs.map(&:text).map(&:strip).join("\n")
      else
        fallback_node = subpage_doc.at_css('div.mlc-offer__description')
        details = fallback_node ? fallback_node.text.strip.gsub(/\s+/, ' ') : "No details"
      end

      seller_section = subpage_doc.at_css('section[data-mlc-seller-details]')

      if seller_section
        raw_json = seller_section['data-mlc-seller-details']
        
        begin
          seller_data = JSON.parse(raw_json)
          location = seller_data.dig('location', 'city') || "No location"
          seller = seller_data.dig('seller', 'name') || "No seller"
        end
      end
    end

    begin
      inserted_id = offers_table.insert(
        title: title, 
        price: price, 
        details: details,
        seller: seller,
        location: location,
        url: link
      )
      puts "   -> Item saved (ID: #{inserted_id})."
    rescue Sequel::Error => e
      puts "   -> DB error: #{e.message}"
    end
  end
end


puts "\n" + "=" * 60
puts "DB CONTENT:"
puts "=" * 60

saved_records = offers_table.all

if saved_records.empty?
  puts "DB is empty."
else
  saved_records.each do |car|
    puts "ID:           #{car[:id]}"
    puts "Title:        #{car[:title]}"
    puts "Price:        #{car[:price]}"
    puts "Seller:       #{car[:seller]}"
    puts "Location:     #{car[:location]}"
    puts "URL:          #{car[:url]}"
    puts "Details:      #{car[:details]}"
    
    puts "-" * 60
  end
  
  puts "Total number of records in table 'offers': #{offers_table.count}"
end