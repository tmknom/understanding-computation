class Stack < Struct.new(:contents)
  def push(character)
    Stack.new([character] + contents)
  end

  def pop
    Stack.new(contents.drop(1))
  end

  def top
    contents.first
  end

  def inspect
    "#<Stack (#{top})#{contents.drop(1).join}>"
  end
end

class PDAConfiguration < Struct.new(:state, :stack)
  STUCK_STATE = Object.new

  def stuck
    PDAConfiguration.new(STUCK_STATE, stack)
  end

  def stuck?
    state == STUCK_STATE
  end
end

class PDARule < Struct.new(:state, :character, :next_state, :pop_character, :push_characters)
  def follow(configuration)
    PDAConfiguration.new(next_state, next_stack(configuration))
  end

  def next_stack(configuration)
    popped_stack = configuration.stack.pop

    push_characters.reverse.inject(popped_stack) { |stack, character| stack.push(character) }
  end

  def applies_to?(configuration, character)
    self.state == configuration.state &&
      self.pop_character == configuration.stack.top &&
      self.character == character
  end
end

class DPDARuleBook < Struct.new(:rules)
  def applies_to?(configuration, character)
    !rule_for(configuration, character).nil?
  end

  def follow_free_moves(configuration)
    if applies_to?(configuration, nil)
      follow_free_moves(next_configuration(configuration, nil))
    else
      configuration
    end
  end

  def next_configuration(configuration, character)
    rule_for(configuration, character).follow(configuration)
  end

  def rule_for(configuration, character)
    rules.detect { |rule| rule.applies_to?(configuration, character) }
  end
end

class DPDA < Struct.new(:current_configuration, :accept_states, :rulebook)
  def next_configuration(character)
    if rulebook.applies_to?(current_configuration, character)
      rulebook.next_configuration(current_configuration, character)
    else
      current_configuration.stuck
    end
  end

  def stuck?
    current_configuration.stuck?
  end

  def current_configuration
    rulebook.follow_free_moves(super)
  end

  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def read_character(character)
    self.current_configuration = next_configuration(character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character) unless stuck?
    end
  end
end

class DPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
  def to_dpda
    start_stack = Stack.new([bottom_character])
    start_configuration = PDAConfiguration.new(start_state, start_stack)
    DPDA.new(start_configuration, accept_states, rulebook)
  end

  def accepts?(string)
    to_dpda.tap { |dpda| dpda.read_string(string) }.accepting?
  end
end

stack = Stack.new(['a', 'b', 'c', 'd', 'e'])
puts stack.top
puts stack.pop.pop.top
puts stack.push('x').push('y').top
puts stack.push('x').push('y').pop.top
puts ""

rule = PDARule.new(1, '(', 2, '$', ['b', '$'])
configuration = PDAConfiguration.new(1, Stack.new(['$']))
puts rule
puts configuration
puts rule.applies_to?(configuration, '(')
puts rule.follow(configuration)
puts ""

rulebook = DPDARuleBook.new(
  [
    PDARule.new(1, '(', 2, '$', ['b', '$']),
    PDARule.new(2, '(', 2, 'b', ['b', 'b']),
    PDARule.new(2, ')', 2, 'b', []),
    PDARule.new(2, nil, 1, '$', ['$']),
  ])
puts configuration = rulebook.next_configuration(configuration, '(')
puts configuration = rulebook.next_configuration(configuration, '(')
puts configuration = rulebook.next_configuration(configuration, ')')
puts ""

dpda = DPDA.new(PDAConfiguration.new(1, Stack.new(['$'])), [1], rulebook)
puts dpda.accepting?
dpda.read_string('(()')
puts dpda.accepting?
puts dpda.current_configuration
puts ""

dpda = DPDA.new(PDAConfiguration.new(2, Stack.new(['$'])), [1], rulebook)
dpda.read_string('(()(')
puts dpda.accepting?
puts dpda.current_configuration
dpda.read_string('))()')
puts dpda.accepting?
puts dpda.current_configuration
puts ""

dpda_design = DPDADesign.new(1, '$', [1], rulebook)
puts dpda_design.accepts?('(((())))')
puts dpda_design.accepts?('()(())(((())))')
puts dpda_design.accepts?('()(())(((()))')
puts dpda_design.accepts?('()(())(((()))))')
puts ""

rulebook = DPDARuleBook.new(
  [
    PDARule.new(1, 'a', 2, '$', ['a', '$']),
    PDARule.new(1, 'b', 2, '$', ['b', '$']),
    PDARule.new(2, 'a', 2, 'a', ['a', 'a']),
    PDARule.new(2, 'b', 2, 'b', ['b', 'b']),
    PDARule.new(2, 'a', 2, 'b', []),
    PDARule.new(2, 'b', 2, 'a', []),
    PDARule.new(2, nil, 1, '$', ['$']),
  ])
dpda_design = DPDADesign.new(1, '$', [1], rulebook)
puts dpda_design.accepts?('ababab')
puts dpda_design.accepts?('bbbaaaab')
puts dpda_design.accepts?('baa')
puts ""

rulebook = DPDARuleBook.new(
  [
    PDARule.new(1, 'a', 1, '$', ['a', '$']),
    PDARule.new(1, 'a', 1, 'a', ['a', 'a']),
    PDARule.new(1, 'a', 1, 'b', ['a', 'b']),
    PDARule.new(1, 'b', 1, '$', ['b', '$']),
    PDARule.new(1, 'b', 1, 'a', ['b', 'a']),
    PDARule.new(1, 'b', 1, 'b', ['b', 'b']),
    PDARule.new(1, 'm', 2, '$', ['$']),
    PDARule.new(1, 'm', 2, 'a', ['a']),
    PDARule.new(1, 'm', 2, 'b', ['b']),
    PDARule.new(2, 'a', 2, 'a', []),
    PDARule.new(2, 'b', 2, 'b', []),
    PDARule.new(2, nil, 3, '$', ['$']),
  ])
dpda_design = DPDADesign.new(1, '$', [3], rulebook)
puts dpda_design.accepts?('abmba')
puts dpda_design.accepts?('babbamabbab')
puts dpda_design.accepts?('abmb')
puts dpda_design.accepts?('baambaa')
