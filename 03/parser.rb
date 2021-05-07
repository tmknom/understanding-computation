require 'bundler'
Bundler.require

Treetop.load('pattern')
parse_tree = PatternParser.new.parse('(a(|b))*')
puts parse_tree.inspect
puts parse_tree.to_ast.inspect
