result = (1..100).map do |n|
  if (n % 15).zero?
    'FizzBuzz'
  elsif (n % 3).zero?
    'Fizz'
  elsif (n % 5).zero?
    'Buzz'
  else
    n.to_s
  end
end
puts result.inspect
puts ""

def to_integer(proc)
  proc[-> n { n + 1 }][0]
end

def to_boolean(proc)
  proc[true][false]
end

def to_array(proc)
  array = []

  until to_boolean(IS_EMPTY[proc])
    array.push(FIRST[proc])
    proc = REST[proc]
  end

  array
end

def to_char(c)
  '0123456789BFiuz'.slice(to_integer(c))
end

def to_string(s)
  to_array(s).map { |c| to_char(c) }.join
end

def if(proc, x, y)
  proc[x][y]
end

def slide(pair)
  [pair.last, pair.last + 1]
end

ZERO = -> p { -> x { x } }
ONE = -> p { -> x { p[x] } }
TWO = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE = -> p { -> x { p[p[p[p[p[x]]]]] } }
FIFTEEN = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]] } }
HUNDRED = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]] } }

Object.send(:remove_const, :TRUE)
Object.send(:remove_const, :FALSE)
TRUE = -> x { -> y { x } }
FALSE = -> x { -> y { y } }

puts to_integer(ZERO)
puts to_integer(THREE)
puts to_integer(FIFTEEN)
puts to_boolean(TRUE)
puts to_boolean(FALSE)
puts ""

IF = -> b {
  -> x {
    -> y {
      b[x][y]
    }
  }
}

puts IF[TRUE]['happy']['sad']
puts IF[FALSE]['happy']['sad']
puts ""

IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }
puts to_boolean(IS_ZERO[ZERO])
puts to_boolean(IS_ZERO[THREE])
puts ""

PAIR = -> x { -> y { -> f { f[x][y] } } }
LEFT = -> p { p[-> x { -> y { x } }] }
RIGHT = -> p { p[-> x { -> y { y } }] }
my_pair = PAIR[THREE][FIVE]
puts to_integer(LEFT[my_pair])
puts to_integer(RIGHT[my_pair])
puts ""

INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } }
SLIDE = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }

puts slide([3, 4]).inspect
puts slide([8, 9]).inspect
puts slide([-1, 0]).inspect
puts slide(slide([-1, 0])).inspect
puts slide(slide(slide([-1, 0]))).inspect
puts slide([0, 0]).inspect
puts slide(slide([0, 0])).inspect
puts slide(slide(slide([0, 0]))).inspect
puts to_integer(DECREMENT[FIVE])
puts to_integer(DECREMENT[FIFTEEN])
puts to_integer(DECREMENT[HUNDRED])
puts to_integer(DECREMENT[ZERO])
puts ""

ADD = -> m { -> n { n[INCREMENT][m] } }
SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
POWER = -> m { -> n { n[MULTIPLY[m]][ONE] } }

IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUBTRACT[m][n]] } }
puts to_boolean(IS_LESS_OR_EQUAL[ONE][TWO])
puts to_boolean(IS_LESS_OR_EQUAL[TWO][TWO])
puts to_boolean(IS_LESS_OR_EQUAL[THREE][TWO])
puts ""

Y = -> f {
  -> x {
    f[x[x]]
  }[-> x { f[x[x]] }]
}

Z = -> f {
  -> x {
    f[-> y { x[x][y] }]
  }[-> x { f[-> y { x[x][y] }] }]
}

MOD = Z[-> f { -> m { -> n {
  IF[IS_LESS_OR_EQUAL[n][m]][
    -> x {
      f[SUBTRACT[m][n]][n][x]
    }
  ][
    m
  ]
} } }]

puts to_integer(MOD[THREE][TWO])
puts to_integer(MOD[POWER[THREE][THREE]][ADD[THREE][TWO]])
puts ""

EMPTY = PAIR[TRUE][TRUE]
UNSHIFT = -> l { -> x { PAIR[FALSE][PAIR[x][l]] } }
IS_EMPTY = LEFT
FIRST = -> l { LEFT[RIGHT[l]] }
REST = -> l { RIGHT[RIGHT[l]] }

my_list = UNSHIFT[
  UNSHIFT[
    UNSHIFT[EMPTY][THREE]
  ][TWO]
][ONE]
puts to_integer(FIRST[my_list])
puts to_integer(FIRST[REST[my_list]])
puts to_integer(FIRST[REST[REST[my_list]]])
puts to_boolean(IS_EMPTY[my_list])
puts to_boolean(IS_EMPTY[EMPTY])
puts to_array(my_list).map { |p| to_integer(p) }.inspect
puts ""

RANGE =
  Z[-> f {
    -> m { -> n {
      IF[IS_LESS_OR_EQUAL[m][n]][
        -> x {
          UNSHIFT[f[INCREMENT[m]][n]][m][x]
        }
      ][
        EMPTY
      ]
    } }
  }]

my_range = RANGE[ONE][FIVE]
puts to_array(my_range).map { |p| to_integer(p) }.inspect

FOLD =
  Z[-> f {
    -> l { -> x { -> g {
      IF[IS_EMPTY[l]][
        x
      ][
        -> y {
          g[f[REST[l]][x][g]][FIRST[l]][y]
        }
      ]
    } } }
  }]

puts to_integer(FOLD[RANGE[ONE][FIVE]][ZERO][ADD])
puts to_integer(FOLD[RANGE[ONE][FIVE]][ONE][MULTIPLY])

MAP =
  -> k { -> f {
    FOLD[k][EMPTY][
      -> l { -> x { UNSHIFT[l][f[x]] } }
    ]
  } }

my_list = MAP[RANGE[ONE][FIVE]][INCREMENT]
puts to_array(my_list).map { |p| to_integer(p) }.inspect

TEN = MULTIPLY[TWO][FIVE]
B = TEN
F = INCREMENT[B]
I = INCREMENT[F]
U = INCREMENT[I]
ZED = INCREMENT[U]

FIZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

puts to_char(ZED)
puts to_string(FIZZBUZZ)
puts ""

DIV =
  Z[-> f { -> m { -> n {
    IF[IS_LESS_OR_EQUAL[n][m]][
      -> x {
        INCREMENT[f[SUBTRACT[m][n]][n]][x]
      }
    ][
      ZERO
    ]
  } } }]

PUSH =
  -> l {
    -> x {
      FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
    }
  }

TO_DIGITS =
  Z[-> f { -> n { PUSH[
    IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][
      EMPTY
    ][
      -> x {
        f[DIV[n][TEN]][x]
      }
    ]
  ][MOD[n][TEN]] } }]

puts to_array(TO_DIGITS[FIVE]).map { |p| to_integer(p) }.inspect
# puts to_array(TO_DIGITS[POWER[FIVE][THREE]]).map { |p| to_integer(p) }.inspect

result = MAP[RANGE[ONE][HUNDRED]][-> n {
  IF[IS_ZERO[MOD[n][FIFTEEN]]][
    FIZZBUZZ
  ][IF[IS_ZERO[MOD[n][THREE]]][
      FIZZ
    ][IF[IS_ZERO[MOD[n][FIVE]]][
        BUZZ
      ][
        TO_DIGITS[n]
      ]]]
}]

puts to_array(result).map { |p| to_string(p) }.inspect
