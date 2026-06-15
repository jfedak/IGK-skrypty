require 'nokogiri'
require 'open-uri'

url = "https://allegrolokalnie.pl/oferty/samochody/osobowe-4029"

begin
  html_content = URI.open(url).read 
  doc = Nokogiri::HTML(html_content, nil, 'UTF-8')
  offers = doc.css('article')

  offers.each_with_index do |offer, index|
    title_node = offer.at_css('h3.mlc-itembox__title')
    title = title_node ? title_node.text.strip : "No title"
    
    price_node = offer.at_css('.ml-offer-price')
    price = price_node ? price_node.text.strip.gsub(/\s+/, ' ') : "No price"

    next if title == "No title" || price == "No price"

    puts "#{index + 1}. Tytuł: #{title}"
    puts "    Cena:  #{price}"
    puts " "
  end
end