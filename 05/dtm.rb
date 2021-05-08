class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<Tape #{left.join}(#{middle})#{right.join}>"
  end

  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end

  def move_head_right
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state,
                          :write_character, :direction)
  def applies_to?(configuration)
    state == configuration.state && character == configuration.tape.middle
  end

  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)

    case direction
    when :left
      written_tape.move_head_left
    when :right
      written_tape.move_head_right
    end
  end
end

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end

  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end

  def stuck?
    !accepting? && !rulebook.applies_to?(current_configuration)
  end
end

tape = Tape.new(['1', '0', '1'], '1', [], '_')
puts tape.inspect
puts tape.move_head_left.inspect
puts tape.write('0').inspect
puts tape.move_head_right.inspect
puts tape.move_head_right.write('0').inspect
puts ""

rule = TMRule.new(1, '0', 2, '1', :right)
puts rule.applies_to?(TMConfiguration.new(1, Tape.new([], '0', [], '_')))
puts rule.applies_to?(TMConfiguration.new(1, Tape.new([], '1', [], '_')))
puts rule.applies_to?(TMConfiguration.new(2, Tape.new([], '0', [], '_')))
puts rule.follow(TMConfiguration.new(1, Tape.new([], '0', [], '_')))
puts ""

rulebook = DTMRulebook.new(
  [
    TMRule.new(1, '0', 2, '1', :right),
    TMRule.new(1, '1', 1, '0', :left),
    TMRule.new(1, '_', 2, '1', :right),
    TMRule.new(2, '0', 2, '0', :right),
    TMRule.new(2, '1', 2, '1', :right),
    TMRule.new(2, '_', 3, '_', :left),
  ])
configuration = TMConfiguration.new(1, tape)
puts configuration = rulebook.next_configuration(configuration)
puts configuration = rulebook.next_configuration(configuration)
puts configuration = rulebook.next_configuration(configuration)
puts ""

dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
puts dtm.current_configuration
puts dtm.accepting?
dtm.step
puts dtm.current_configuration
puts dtm.accepting?
dtm.run
puts dtm.current_configuration
puts dtm.accepting?
puts ""

tape = Tape.new(['1', '2', '1'], '1', [], '_')
dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
dtm.run
puts dtm.accepting?
puts dtm.stuck?
puts ""

rulebook = DTMRulebook.new(
  [
    # state 1: scan right looking for a
    TMRule.new(1, 'X', 1, 'X', :right), # skip X
    TMRule.new(1, 'a', 2, 'X', :right), # cross out a, go to state 2
    TMRule.new(1, '_', 6, '_', :left), # find blank, go to state 6 (accept)

    # state 2: scan right looking for b
    TMRule.new(2, 'a', 2, 'a', :right), # skip a
    TMRule.new(2, 'X', 2, 'X', :right), # skip X
    TMRule.new(2, 'b', 3, 'X', :right), # cross out b, go to state 3

    # state 3: scan right looking for c
    TMRule.new(3, 'b', 3, 'b', :right), # skip b
    TMRule.new(3, 'X', 3, 'X', :right), # skip X
    TMRule.new(3, 'c', 4, 'X', :right), # cross out c, go to state 4

    # state 4: scan right looking for end of string
    TMRule.new(4, 'c', 4, 'c', :right), # skip c
    TMRule.new(4, '_', 5, '_', :left), # find blank, go to state 5

    # state 5: scan left looking for beginning of string
    TMRule.new(5, 'a', 5, 'a', :left), # skip a
    TMRule.new(5, 'b', 5, 'b', :left), # skip b
    TMRule.new(5, 'c', 5, 'c', :left), # skip c
    TMRule.new(5, 'X', 5, 'X', :left), # skip X
    TMRule.new(5, '_', 1, '_', :right) # find blank, go to state 1
  ])
tape = Tape.new([], 'a', ['a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'], '_')
dtm = DTM.new(TMConfiguration.new(1, tape), [6], rulebook)
10.times { dtm.step }
puts dtm.current_configuration
25.times { dtm.step }
puts dtm.current_configuration
dtm.run
puts dtm.current_configuration
