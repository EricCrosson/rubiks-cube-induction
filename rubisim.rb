#!/usr/bin/env ruby
require 'rubiks_cube'

VALID_INPUT = %w(U D L R F B U' D' L' R' F' B')
# Returns a list of all possible input sequences
# Params:
# +length+:: length of each sequence to return
def sequences_of_length(length)
  VALID_INPUT.combination(length).to_a.reject do |sequence|
    sequence.each_cons(2).any? do |a, b|
      a == b.sub("'", '') || b == a.sub("'", '')
    end
  end
end

# Returns the number of times SEQUENCE must be input on a rubik's cube before
# the cube returns to its solved state
# +sequence+:: sequence to repeatedly input on the rubik's cube
def repeat_sequence_until_solved(sequence)
  cube = RubiksCube::Cube.new
  cube.perform! sequence
  repetitions = 1
  until cube.solved?
    cube.perform! sequence
    repetitions += 1
  end
  repetitions
end

length = 0

loop do
  length += 1
  puts "Starting trials of length #{length}"
  sequences = sequences_of_length(length)
  sequences.each do |seq|
    sequence = seq.join(' ')
    reps = repeat_sequence_until_solved(sequence)
    puts "Sequence #{sequence} took #{reps} repetitions to reset"
  end
end
