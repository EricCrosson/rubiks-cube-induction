#!/usr/bin/env ruby
require 'rubiks_cube'

def sequences_of_length(length)
  %w(U D L R F B U' D' L' R' F' B').combination(length).to_a.reject do |sequence|
    sequence.each_cons(2).any? { |a,b| a == b.sub("'",'') or b == a.sub("'",'') }
  end
end

def repeat_sequence_until_solved(sequence)
  cube = RubiksCube::Cube.new
  cube.perform! sequence
  repetitions = 1
  while !cube.solved?
    cube.perform! sequence
    repetitions += 1
  end
  repetitions # return number of times to perform sequence until cube
  # is in solved state
end

length = 0

begin
  loop do
    length += 1
    puts "Starting trials of length #{length}"
    sequences = sequences_of_length(length)
    sequences.each do |seq|
      reps = repeat_sequence_until_solved(seq.join(' '))
      puts "Sequence #{seq} took #{reps} repetitions to reset"
    end
  end
rescue Interrupt, SystemExit
end