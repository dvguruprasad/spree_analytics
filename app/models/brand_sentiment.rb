class BrandSentiment
  attr_accessor :tags, :scores, :reach, :passion, :brand

  @base_url = "http://10.10.5.106:8080/ws/score/"

  def self.create(brand)
      response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
      json_response = JSON.parse(response.body)
      sentiment = BrandSentiment.new
      sentiment.brand = brand
      sentiment.tags = tags(json_response)
      sentiment.scores = sentiment(json_response)
      sentiment.passion = passion(json_response)
      sentiment.reach = reach(json_response)
      sentiment
  end
  
  private
  def self.tags(json_response)
    json_response['tags'].to_json
  end
  
  def self.reach(json_response)
    reach = json_response['unique_users']["positive"] + json_response["unique_users"]["negative"]
  end
 
  def self.passion(json_response)
      passion = {:positive => compute_passion(json_response, "positive"),
          :negative => compute_passion(json_response, "negative")}
  end

  def self.sentiment(json_response)
    sentiment = json_response['sentiment']
    result = sentiment['percentage'].map do |emotion,value|
      [emotion,value]
    end
    result.to_json
  end

  private
  def self.compute_passion(json_response, sentiment)
      (json_response['repeat_users'][sentiment] / json_response["unique_users"][sentiment].to_f).round(2) * 100
  end
end
