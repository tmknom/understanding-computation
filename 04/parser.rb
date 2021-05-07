require 'set'

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

class NPDARuleBook < Struct.new(:rules)
  def follow_free_moves(configurations)
    more_configurations = next_configurations(configurations, nil)
    if more_configurations.subset?(configurations)
      configurations
    else
      follow_free_moves(configurations + more_configurations)
    end
  end

  def next_configurations(configurations, character)
    configurations.flat_map { |config| follow_rule_for(config, character) }.to_set
  end

  def follow_rule_for(configuration, character)
    rules_for(configuration, character).map { |rule| rule.follow(configuration) }
  end

  def rules_for(configuration, character)
    rules.select { |rule| rule.applies_to?(configuration, character) }
  end
end

class NPDA < Struct.new(:current_configurations, :accept_states, :rulebook)
  def accepting?
    current_configurations.any? { |config| accept_states.include?(config.state) }
  end

  def read_character(character)
    self.current_configurations = rulebook.next_configurations(current_configurations, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end

  def current_configurations
    rulebook.follow_free_moves(super)
  end
end

class NPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
  def to_npda
    start_stack = Stack.new([bottom_character])
    start_configuration = PDAConfiguration.new(start_state, start_stack)
    NPDA.new(Set[start_configuration], accept_states, rulebook)
  end

  def accepts?(string)
    to_npda.tap { |npda| npda.read_string(string) }.accepting?
  end
end

class LexicalAnalyzer < Struct.new(:string)
  GRAMMAR = [
    { token: 'i', pattern: /if/ }, # if keyword
    { token: 'e', pattern: /else/ }, # else keyword
    { token: 'w', pattern: /while/ }, # while keyword
    { token: 'd', pattern: /do-nothing/ }, # do-nothing keyword
    { token: '(', pattern: /\(/ }, # opening bracket
    { token: ')', pattern: /\)/ }, # closing bracket
    { token: '{', pattern: /\{/ }, # opening curly bracket
    { token: '}', pattern: /\}/ }, # closing curly bracket
    { token: ';', pattern: /;/ }, # semicolon
    { token: '=', pattern: /=/ }, # equals sign
    { token: '+', pattern: /\+/ }, # addition sign
    { token: '*', pattern: /\*/ }, # multiplication sign
    { token: '<', pattern: /</ }, # less-than sign
    { token: 'n', pattern: /[0-9]+/ }, # number
    { token: 'b', pattern: /true|false/ }, # boolean
    { token: 'v', pattern: /[a-z]+/ } # variable name
  ]

  def analyze
    [].tap do |tokens|
      while more_tokens?
        tokens.push(next_token)
      end
    end
  end

  def more_tokens?
    !string.empty?
  end

  def next_token
    rule, match = rule_matching(string)
    self.string = string_after(match)
    rule[:token]
  end

  def rule_matching(string)
    matches = GRAMMAR.map { |rule| match_at_beginning(rule[:pattern], string) }
    rules_with_matches = GRAMMAR.zip(matches).reject { |rule, match| match.nil? }
    rule_with_longest_match(rules_with_matches)
  end

  def match_at_beginning(pattern, string)
    /\A#{pattern}/.match(string)
  end

  def rule_with_longest_match(rules_with_matches)
    rules_with_matches.max_by { |rule, match| match.to_s.length }
  end

  def string_after(match)
    match.post_match.lstrip
  end
end

puts LexicalAnalyzer.new('y = x * 7').analyze.inspect
puts LexicalAnalyzer.new('while (x<5) { x=x*3 }').analyze.inspect
puts ""

start_rule = PDARule.new(1, nil, 2, '$', ['S', '$'])
symbol_rules = [
  # <statement> ::= <while> | <assign>
  PDARule.new(2, nil, 2, 'S', ['W']),
  PDARule.new(2, nil, 2, 'S', ['A']),

  # <while> ::= 'w' '(' <expression> ')' '{' <statement> '}'
  PDARule.new(2, nil, 2, 'W', ['w', '(', 'E', ')', '{', 'S', '}']),

  # <assign> ::= 'v' '=' <expression>
  PDARule.new(2, nil, 2, 'A', ['v', '=', 'E']),

  # <expression> ::= <less-than>
  PDARule.new(2, nil, 2, 'E', ['L']),

  # <less-than> ::= <multiply> '<' <less-than> | <multiply>
  PDARule.new(2, nil, 2, 'L', ['M', '<', 'L']),
  PDARule.new(2, nil, 2, 'L', ['M']),

  # <multiply> ::= <term> '*' <multiply> | <term>
  PDARule.new(2, nil, 2, 'M', ['T', '*', 'M']),
  PDARule.new(2, nil, 2, 'M', ['T']),

  # <term> ::= 'n' | 'v'
  PDARule.new(2, nil, 2, 'T', ['n']),
  PDARule.new(2, nil, 2, 'T', ['v']),
]

token_rules = LexicalAnalyzer::GRAMMAR.map do |rule|
  PDARule.new(2, rule[:token], 2, rule[:token], [])
end
stop_rule = PDARule.new(2, nil, 3, '$', ['$'])
rulebook = NPDARuleBook.new([start_rule, stop_rule] + symbol_rules + token_rules)
npda_design = NPDADesign.new(1, '$', [3], rulebook)
token_string = LexicalAnalyzer.new('while (x<5) { x=x*3 }').analyze.join
puts token_string
puts npda_design.accepts?(token_string)
puts npda_design.accepts?(LexicalAnalyzer.new('while (x<5 x=x*3 }').analyze.join)
