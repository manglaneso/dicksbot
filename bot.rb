#!/usr/bin/env ruby
require 'telegram/bot'
require 'json'
require 'net/http'
token = ''

def getRekt(uri)
  url = URI.parse(uri)
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  @ret = res
end

def getRandom()
  get = getRekt('http://dicks-api.herokuapp.com/dicks/1')
  data = JSON.parse(get.body)
  @ret = data['dicks'][0]
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    begin
      case message
      when Telegram::Bot::Types::InlineQuery
        results = [
          [1, 'Cute', '8===D'],
          [2, 'Average', '8=====D'],
          [3, 'XL', '8==============D'],
          [4, 'Random', getRandom]
        ].map do |arr|
          Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: arr[0],
            title: arr[1],
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: arr[2])
          )
        end
        bot.api.answer_inline_query(inline_query_id: message.id, results: results)
      when Telegram::Bot::Types::Message
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!")
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      puts e.message
    end
  end
end
