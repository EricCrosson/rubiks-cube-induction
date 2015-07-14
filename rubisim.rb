#!/usr/bin/env ruby
require 'rubiks_cube'
require 'yaml'

VALID_MOVES    = %w(U D L R F B M U' D' L' R' F' B' M').freeze
INVERSE        = %{'}.freeze
MOVE_SEPARATOR = %{ }.freeze

def inverse_of(move)
  if move.nil?
    nil
  elsif move.length > 1
    move[0]
  else
    move += INVERSE
  end
end

# define methods to generate random legal move sequence of variable
# length
def move_sequence(length)
  # Prevent sequences of zero length
  length = 1 if length.zero?
  last_move = nil
  str = String.new
  length.times do
    # Don't move back and forth forever
    new_move = VALID_MOVES.reject{|m| m == inverse_of(last_move)}.sample
    str += new_move + MOVE_SEPARATOR
    last_move = new_move
  end
  str
end

def repeat_sequence_until_solved(scramble)
  cube = RubiksCube::Cube.new
  cube.perform! scramble
  repetitions = 1
  while !cube.solved?
    cube.perform! scramble
    repetitions += 1
  end
  repetitions # return number of times to perform scramble until cube
              # is in solved state
end

YAML_LOG            = './attempted_trials.yml'
attempted_trials    = YAML::load(File.read(YAML_LOG)) || Hash.new
NUMBER_OF_TRIALS    = (ARGV[0] || '10_000_000').to_i.freeze
max_sequence_length = (ARGV[1] || '1').to_i
retry_upper_bound   = VALID_MOVES.length ** max_sequence_length
debug               = ARGV[2].freeze

puts "Starting off adding to the #{attempted_trials.size} existing recorded scrambles"

successful_scrambles = 0
begin
  NUMBER_OF_TRIALS.times do
    scramble = move_sequence(max_sequence_length)
    need_to_increase_max_sequence_length = 0
    while attempted_trials.has_key? scramble
      if (need_to_increase_max_sequence_length += 1) >= retry_upper_bound
        max_sequence_length += 1
        retry_upper_bound = VALID_MOVES.length ** max_sequence_length
        puts "Increasing max_sequence_length to #{max_sequence_length}"
      end
      scramble = move_sequence(max_sequence_length)
    end
    puts "Detected new scramble: #{scramble}"
    repeats_until_solved = repeat_sequence_until_solved(scramble)
    puts "  iterations until solved: #{repeats_until_solved}"
    puts

    # Record trial
    attempted_trials[scramble] = repeats_until_solved
    successful_scrambles += 1
  end
rescue Interrupt, SystemExit
  puts "You opted to terminate program execution after #{successful_scrambles} successful scrambles"
ensure
  # Save new trial runs
  File.open(YAML_LOG, 'w') {|f| f.write attempted_trials.to_yaml}
  puts "Total recorded successful scrambles: #{attempted_trials.size}"
end
