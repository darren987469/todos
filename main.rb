require 'nokogiri'
require 'nokogiri'
require 'restclient'

page = Nokogiri::HTML(RestClient.get("https://online.carrefour.com.tw/%E5%86%B7%E8%97%8F%E9%A3%9F%E5%93%81-2"))

page.css('.item-product').each do |item|

end