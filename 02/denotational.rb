class Number < Struct.new(:value)
  def to_ruby
    "-> e { #{value.inspect} }"
  end

  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Boolean < Struct.new(:value)
  def to_ruby
    "-> e { #{value.inspect} }"
  end

  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Variable < Struct.new(:name)
  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end

  def to_s
    name.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Add < Struct.new(:left, :right)
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end

  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class Multiply < Struct.new(:left, :right)
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end

  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class LessThan < Struct.new(:left, :right)
  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end

  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class Assign < Struct.new(:name, :expression)
  def to_ruby
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end

  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<#{self}>"
  end
end

class DoNothing
  def to_ruby
    "-> e { e }"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def to_s
    'do-nothing'
  end

  def inspect
    "<#{self}>"
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_ruby
    "-> e { if (#{condition.to_ruby}).call(e)" +
      "then (#{consequence.to_ruby}).call(e)" +
      "else (#{alternative.to_ruby}).call(e)" +
      "end }"
  end

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<#{self}>"
  end
end

class Sequence < Struct.new(:first, :second)
  def to_ruby
    "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e))}"
  end

  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<#{self}>"
  end
end

class While < Struct.new(:condition, :body)
  def to_ruby
    "-> e { " +
      "while (#{condition.to_ruby}).call(e);" +
      "e = (#{body.to_ruby}).call(e);" +
      "end;" +
      "e" +
      "}"
  end

  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<#{self}>"
  end
end

puts Number.new(2).to_ruby
puts Boolean.new(false).to_ruby
puts eval(Number.new(2).to_ruby).call({})
puts eval(Boolean.new(false).to_ruby).call({})
puts ""

expression = Variable.new(:x)
puts expression
puts expression.to_ruby
puts eval(expression.to_ruby).call({ x: 7 })
puts ""

add = Add.new(Variable.new(:x), Number.new(1)).to_ruby
puts add
puts eval(add).call({ x: 3 })
puts ""

lessthan = LessThan.new(
  Add.new(Variable.new(:x), Number.new(1)),
  Number.new(3)
).to_ruby
puts lessthan
puts eval(lessthan).call({ x: 3 })
puts ""

assign_statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1))).to_ruby
puts assign_statement
puts eval(assign_statement).call({ x: 3 })
puts ""

sequence_statement = Sequence.new(
  Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))),
).to_ruby
puts sequence_statement
puts eval(sequence_statement).call({})
puts ""

while_statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))),
).to_ruby
puts while_statement
puts eval(while_statement).call({ x: 1 })
