class BrandSentiment
  attr_accessor :tags, :scores, :reach, :passion, :brand

  @base_url = "http://10.10.5.106:8080/ws/score/"

  def self.create(brand)
      # response = Net::HTTP.get_response(URI.parse("#{@base_url}#{brand}"))
      # json_response = JSON.parse(response.body)
      body = <<-HERE
         {"tags":[{"name":"reebok","count":1.0},{"name":"giveaway","count":0.725},{"name":"getafterit","count":0.4125},
            {"name":"crossfit","count":0.38125},{"name":"pls","count":0.35625},{"name":"bwfc","count":0.31875},
            {"name":"reebokpump","count":0.275},{"name":"ifollowback","count":0.24375},{"name":"fitfluential","count":0.21875},
            {"name":"sneakers","count":0.19375},{"name":"discount","count":0.18125},{"name":"amillibound","count":0.15},
            {"name":"fashion","count":0.11875},{"name":"ebay","count":0.1},{"name":"frugal","count":0.0875},
            {"name":"igsneakercommunity","count":0.08125},{"name":"lfc","count":0.08125},{"name":"riedle","count":0.08125},{"name":"reebokclassics","count":0.08125},{"name":"streetwear","count":0.075}],
            "sentiment":{"tweets":{"total":57375,"negative":9859,"positive":16661,"neutral":30855},"percentage":{"negative":0.17183442,"positive":0.2903878,"neutral":0.5377778}},
            "unique_users":{"positive" : 180, "negative" : 120},"repeat_users":{"positive" : 80, "negative" : 20},"entity":"REEBOK"}
      HERE
      json_response = JSON.parse(body)
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
