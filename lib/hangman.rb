require 'yaml'

puts 'Start Hangman'

def random_word
  word_list = File.readlines('wordlist.txt') if File.exist?('wordlist.txt')
  word_list.delete_if { |line| line.length < 5 || line.length > 13 }
  word_list.sample.upcase
end

def ask_for_input
  puts 'Guess a letter. If you would like to come back to your game later, type "save".'
end

def get_guess(guess = gets.chomp.upcase)
  guess
end

def ask_to_load
  puts 'Would you like to load a previous game?'
end

def get_load(input = gets.chomp)
  input
end

def check_guess(secret_word, tracked_word, guess)
  secret_word.each_index do |letter|
    tracked_word[letter] = guess if secret_word[letter] == guess
  end
end

def save_game(secret_word, tracked_word, remaining_guesses)
  output = File.open('save.yaml', 'w')
  output.puts YAML.dump('secret_word': secret_word, 'tracked_word': tracked_word, 'remaining_guesses': remaining_guesses)
  output.close
end

def load_game
  YAML.load(File.read('save.yaml'))
end

def play
  remaining_guesses = 6
  secret_word = random_word.chomp.split(//)
  tracked_word = Array.new(secret_word.length) { '_' }
  keep_going = true
  ask_to_load
  if get_load == 'y'
    tmp = load_game
    secret_word = tmp[:secret_word]
    tracked_word = tmp[:tracked_word]
    remaining_guesses = tmp[:remaining_guesses]
  end

  while keep_going
    ask_for_input
    guess = get_guess
    if guess == 'SAVE'
      save_game(secret_word, tracked_word, remaining_guesses)
      keep_going = false
    else
      check_guess(secret_word, tracked_word, guess)
      remaining_guesses -= 1 unless secret_word.include?(guess)
      puts "Remaining misses: #{remaining_guesses}"
      puts tracked_word.join(' ')
      unless tracked_word.include?('_')
        puts 'You win!'
        keep_going = false
      end
      if remaining_guesses < 1
        puts "The word was #{secret_word.join.downcase}. You lose!"
        keep_going = false
      end
    end
  end
end

play