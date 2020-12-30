require 'json'

#THIS CLASS WILL CONTAIN DATA AND METHODS RELATED TO STARTING A NEW OR SAVED GAME
class Start
#METHOD TO START PROGRAM
  def self.program()
    puts "Would you like to start a new $game (1) or load a save file (2)?"
    answer = gets.chomp
    puts answer

    while answer != "1" && answer != "2"
      puts "Please enter valid answer '1' or '2'"
      answer = gets.chomp
    end

    if answer == "1" then 
      Start.game
    elsif answer == "2" then
    end
  end

#STARTING NEW GAME
  def self.game()
    $game = Hangman.new()
  end

#LOADING SAVED GAME
#METHOD TO START SAVED GAME
  def self.save()
    
  end

  def self.from_json(save_file)
    data = JSON.load save_file
    self.new(data['name'], data['attempts'], data['guesses'], data['word'])
  end
end

#THIS CLASS WILL CONTAIN DATA AND METHODS RELATED TO PLAYING THE GAME
class Hangman
  attr_accessor :attempts, :guesses

#STARTING A NEW GAME
  def initialize(name = "", attempts = 10, guesses = [], word = new_word())
    @name = name
    @attempts = attempts
    @guesses = guesses
    @word = {"word" => word, 
             "guessing" => {"hidden word" => word.split("").map { |letter| letter = "_ " }.join(""), 
                            "guesses" => @guesses
            }} 
  end

  def new_word
    "plain"
  end

#PLAYING THE GAME
  def take_turn()
    puts "The word you are guessing: #{@word["guessing"]["hidden word"]}"
    puts "Your guesses: #{@guesses}, Your remaining attempts #{@attempts}"

    case make_guess
    when true
      if @word["word"] == @word["guessing"]["hidden word"].split(" ").join("")
        puts "You have guessed the word!!"
        @attempts = 0
      else
        puts "You have guessed correctly"
        @attempts -= 1
      end
    when false
      puts "You have guessed incorrectly"
      @attempts -= 1
    end
  end

  def make_guess()
    puts "Make a guess"
    guess = gets.chomp.downcase

    while !guess.match?(/[a-z]/) || @guesses.include?(guess)
      puts "Your guess is either invalid or you have already guessed this letter"
      puts "Make a valid guess"
      guess = gets.chomp.downcase
    end

    @guesses.push(guess)
    return update_hidden_word()
  end

  def update_hidden_word()
    prev_hidden_word = @word["guessing"]["hidden word"]

    @word["guessing"]["hidden word"] = @word["word"].split("").map { |letter| 
      @guesses.include?(letter) ? "#{letter} " : "_ " }.join("")

    new_hidden_word = @word["guessing"]["hidden word"]

    prev_hidden_word == new_hidden_word ? false : true
  end

#SAVING GAME
  def to_json
    JSON.dump({
      :name => @name,
      :attempts => @attempts,
      :guesses => @guesses,
      :word => @word
    },
      new_save_file(@name))
  end
 
  def new_save_file()
    Dir.mkdir("Saves") unless Dir.exists?("Saves")
    save_name = "Saves/#{name}_save.json"
    new_save_file = File.open(save_name, 'w')
  end
end

puts "Hangman Initialized"
Start.program

while $game.attempts > 0 do
  $game.take_turn()
end

puts "Game has finished"
