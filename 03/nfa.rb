require 'set'

class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
end

class NFARuleBook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character) }.to_set
  end

  def follow_rules_for(state, character)
    rule_for(state, character).map(&:follow)
  end

  def rule_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)
    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end

  def current_states
    rulebook.follow_free_moves(super)
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end

  def accepts?(string)
    to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
  end
end

rulebook = NFARuleBook.new(
  [
    FARule.new(1, 'a', 1),
    FARule.new(2, 'a', 3),
    FARule.new(3, 'a', 4),
    FARule.new(1, 'b', 1),
    FARule.new(1, 'b', 2),
    FARule.new(2, 'b', 3),
    FARule.new(3, 'b', 4),
  ])

puts rulebook.next_states(Set[1], 'b')
puts rulebook.next_states(Set[1, 2], 'a')
puts rulebook.next_states(Set[1, 3], 'b')
puts ""

nfa = NFA.new(Set[1], [4], rulebook)
puts nfa.accepting?

nfa.read_character('b')
puts nfa.accepting?

nfa.read_character('a')
puts nfa.accepting?

nfa.read_character('b')
puts nfa.accepting?

puts ""

nfa = NFA.new(Set[1], [4], rulebook)
puts nfa.accepting?

nfa.read_string('bbbbb')
puts nfa.accepting?

puts ""

nfa_design = NFADesign.new(1, [4], rulebook)
puts nfa_design.accepts?('bab')
puts nfa_design.accepts?('bbbbb')
puts nfa_design.accepts?('bbabb')
puts ""

rulebook = NFARuleBook.new(
  [
    FARule.new(1, nil, 2),
    FARule.new(1, nil, 4),
    FARule.new(2, 'a', 3),
    FARule.new(3, 'a', 2),
    FARule.new(4, 'a', 5),
    FARule.new(5, 'a', 6),
    FARule.new(6, 'a', 4),
  ])

puts rulebook.next_states(Set[1], nil)
puts rulebook.follow_free_moves(Set[1])
puts ""

nfa_design = NFADesign.new(1, [2, 4], rulebook)
puts nfa_design.accepts?('aa')
puts nfa_design.accepts?('aaa')
puts nfa_design.accepts?('aaaaa')
puts nfa_design.accepts?('aaaaaa')
puts ""
