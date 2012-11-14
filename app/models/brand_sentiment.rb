class BrandSentiment
  attr_accessor :tags, :scores, :reach, :passion

  @base_url = "http://10.10.5.106:8080/ws/score/"

  def self.create(brand)
      sentiment = BrandSentiment.new
      sentiment.tags = tags(brand)
      sentiment.scores = sentiment(brand)
      sentiment.passion = passion(brand)
      sentiment.reach = reach(brand)
      sentiment
  end
  
  private
  def self.tags(brand)
    response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
    JSON.parse(response.body)['tags'].to_json
  end
  
  def self.reach(brand)
    response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
    JSON.parse(response.body)['unique_users']
  end
 
  def self.passion(brand)
    response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
    JSON.parse(response.body)['repeat_users']
  end


  def self.sentiment(brand)
    response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
    sentiment = JSON.parse(response.body)['sentiment']
    result = sentiment['percentage'].map do |emotion,value|
      [emotion,value]
    end
    result.to_json
  end
end