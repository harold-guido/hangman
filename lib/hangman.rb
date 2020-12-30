require 'json'

#THIS CLASS WILL CONTAIN DATA AND METHODS RELATED TO STARTING A NEW OR SAVED GAME
class Start
#METHOD TO START PROGRAM
  def self.program()
    puts ""
    puts "Would you like to start a new game (1), load a save file (2) or quit the program (3)?"
    answer = gets.chomp

    while answer != "1" && answer != "2" && answer != "3"
      puts "Please enter valid answer '1', '2' or '3'"
      answer = gets.chomp
    end

    case answer
    when "1" 
      Start.game
      return 1
    when "2"
      Start.save
      return 1
    when "3"
      return 0
    end
  end

#STARTING NEW GAME
  def self.game()
    $game = Hangman.new()
  end

#LOADING SAVED GAME
#METHOD TO START SAVED GAME
  def self.save()
    save_file_list = File.open("saves/saves_log.txt").readlines.map(&:chomp)
    save_file_name = ""
    if save_file_list.length == 0 then
      puts "There are currently no save files available"
    else
      save_file_list.each_with_index do |line, index|
        puts "Enter the number of the save you wish to load"
        puts "#{index+1} - #{line}"

        load_index = ""
        while load_index == ""
          load_index = gets.chomp 
          begin
            save_file_name = save_file_list[load_index.to_i - 1]
          rescue
            puts "Please choose a valid save file"
            load_index = ""
          end
        end
        $game = Hangman.from_json(File.open("saves/#{save_file_name}").read)
      end
    end
  end
end

#THIS CLASS WILL CONTAIN DATA AND METHODS RELATED TO PLAYING THE GAME
class Hangman
  attr_accessor :attempts, :guesses

#STARTING A NEW GAME
  def initialize(name = "", guesses = [], word = new_word(), attempts = word.length * 2)
    @name = name
    @guesses = guesses
    if word.is_a?(String) then
      @word = {"word" => word, 
               "guessing" => {"hidden word" => word.split("").map { |letter| letter = "_ " }.join(""), 
                              "guesses" => @guesses}} 
    else
      @word = word
    end
    @attempts = attempts
  end

  def new_word()
    word_file = File.open("wordlist.txt")
    dictionary = word_file.readlines.map(&:chomp)
    word_file.close
    
    valid_word = false
    while valid_word == false
      word = dictionary[rand((dictionary.length() -1))]
      word[0].match?(/[a-z]/) && word.length > 4 && word.length < 12 ? valid_word = true : valid_word = false 
    end
    word
  end

#PLAYING THE GAME
  def take_turn()
    puts ""
    puts "The word you are guessing: #{@word["guessing"]["hidden word"]}"
    puts "Your guesses: #{@guesses}, Your remaining attempts #{@attempts}"

    puts ""
    puts "Would you like to make a guess (1), save the current game? (2) or exit the current game (3)"
    choice = gets.chomp
    while choice != "1" && choice != "2" && choice != "3" do
      puts "Enter a valid choice, '1', '2' or '3'"
      choice = gets.chomp
    end

    case choice
      #PLAYER MAKES GUESS, TURN GOES ON AS NORMAL
    when "1"
      case make_guess
      when true
        if @word["word"] == @word["guessing"]["hidden word"].split(" ").join("")
          puts ""
          puts "You have guessed the word!!"
          @attempts = 0
        else
          puts ""
          puts "You have guessed correctly"
          @attempts -= 1
        end
      when false
        puts "You have guessed incorrectly"
        @attempts -= 1
      end

      #PLAYER SAVES FILE
    when "2"
      puts ""
      puts "Please name your save"
      puts "The name must only have letters and be between 6 and 12 characters long"
      @name = gets.chomp

      #CHECKING FOR INVALID CHARACTERS
      while check_valid_characters(@name) != 0 || @name.length < 6 || @name.length > 12 do
        puts ""
        puts "Pease enter a proper name"
        puts "It must only have letters and be between 6 and 12 characters long"
        @name = gets.chomp
      end

      $game.to_json()
      @attempts = 0
    when "3"
      @attempts = 0
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

  def check_valid_characters(word)
      invalid_letter_counter = 0
      
      word.length.times do |i|
        word[0].match(/[A-Za-z]/) ? invalid_letter_counter = invalid_letter_counter: invalid_letter_counter += 1
      end
      
      invalid_letter_counter
  end

#SAVING GAME
  def to_json()
    JSON.dump({
      :name => @name,
      :attempts => @attempts,
      :guesses => @guesses,
      :word => @word
    },
      new_save_file())
  end
 
  def new_save_file()
    Dir.mkdir("saves") unless Dir.exists?("saves")
    save_name = "Saves/#{@name}.json"
    new_save_file = File.open(save_name, 'w')
    
    update_save_log("#{@name}.json")
    
    return new_save_file
  end

  def update_save_log(save_name)
    save_log = File.open("saves/saves_log.txt")
    prev_save_files = save_log.readlines.map(&:chomp)

    if !prev_save_files.include?(save_name) then 
      File.write("saves/saves_log.txt", "#{save_name}\n", mode: "a") 
    end
  end

  def self.from_json(json)
    json_data = JSON.load json
    hash_data = json_data.to_h

    Hangman.new(hash_data["name"], hash_data["guesses"], hash_data["word"], hash_data["attempts"]) 
  end
end

puts "Hangman Initialized"

state = Start.program
while state != 0 do
  begin
    while $game.attempts > 0 do
      $game.take_turn()
    end
    state = Start.program
  rescue
    state = Start.program
  end
end

puts "Game has finished"
