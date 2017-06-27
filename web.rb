require 'sinatra'
require 'sinatra/logger'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["0a1744386b8dadccb2f269667dbf298c"]
    config.channel_token = ENV["EBS3nA6f0y6z8EISusYXtZoGexa16VIez9K7umad43E4Sjvv7rwT7VI7Nv4G1bXiJP4Zu/nIjHw/akTJf7xP+KcMmBwTWHyWFKCYlUWBAIZmd+nyEUqXi6cykhBaOFCEsxwMglEyHaD4QxlJlusOEAdB04t89/1O/w1cDnyilFU="]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        say_message = event.message['text']
        message = {
          type: 'text',
          text: "reply: #{say_message}"
        }
        response = client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  "OK"
end
