class Number < Struct.new(:value)
  def evaluate(environment)
    self
  end

  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Boolean < Struct.new(:value)
  def evaluate(environment)
    self
  end

  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Variable < Struct.new(:name)
  def evaluate(environment)
    environment[name]
  end

  def to_s
    name.to_s
  end

  def inspect
    "<#{self}>"
  end
end

class Add < Struct.new(:left, :right)
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end

  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class Multiply < Struct.new(:left, :right)
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end

  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class LessThan < Struct.new(:left, :right)
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end

  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<#{self}>"
  end
end

class Assign < Struct.new(:name, :expression)
  def evaluate(environment)
    environment.merge({ name => expression.evaluate(environment) })
  end

  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<#{self}>"
  end
end

class DoNothing
  def evaluate(environment)
    environment
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
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<#{self}>"
  end
end

class Sequence < Struct.new(:first, :second)
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end

  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<#{self}>"
  end
end

class While < Struct.new(:condition, :body)
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end

  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<#{self}>"
  end
end

puts Number.new(2).evaluate({})
puts Variable.new(:x).evaluate({ x: Number.new(23) })
puts LessThan.new(
  Add.new(Variable.new(:x), Number.new(2)),
  Variable.new(:y)
).evaluate({ x: Number.new(2), y: Number.new(5) })

sequence_statement = Sequence.new(
  Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))),
)
puts sequence_statement
puts sequence_statement.evaluate({})
puts ""

while_statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))),
)
puts while_statement
puts while_statement.evaluate({ x: Number.new(1) })
