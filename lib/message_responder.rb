require './lib/message_sender'
require 'yaml'

class MessageResponder
  attr_reader :message
  attr_reader :bot

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @from_file = YAML.load_file('actors.yml')
    @messages = YAML.load_file('messages.yml')
  end

  def respond
    p message
    if message.text == '/start'
      answer_with_greeting_message
    elsif message.text == '/stop'
      answer_with_farewell_message
    elsif message.text != nil
      answer = @from_file[message.text.split.map(&:capitalize).join(' ')].to_s
      if answer == ''
        # answer = 'No data or wrong actor name'
        answer = @messages[rand(@messages.length)].to_s
      end
      p answer
      answer_with_message(answer)
    else
      answer = @messages[rand(@messages.length)].to_s
      p answer
      answer_with_message(answer)
    end
  end

  private

  def on(regex, &block)
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message 'Привет братюня'
  end

  def answer_with_farewell_message
    answer_with_message 'Пока мой герой'
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
