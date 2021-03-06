require File.expand_path("../../helpers", __FILE__)

%w{
  alternation anchors errors escapes free_space groups
  properties quantifiers refcalls sets
}.each do|tc|
  require File.expand_path("../test_#{tc}", __FILE__)
end

if RUBY_VERSION >= '2.0.0'
  %w{conditionals keep}.each do|tc|
    require File.expand_path("../test_#{tc}", __FILE__)
  end
end

class TestParser < Test::Unit::TestCase

  def test_parse_returns_a_root_expression
    assert_instance_of( Regexp::Expression::Root, RP.parse('abc'))
  end


  def test_parse_root_contains_expressions
    root = RP.parse(/^a.c+[^one]{2,3}\b\d\\\C-C$/)

    assert( root.expressions.all?{|exp|
      exp.kind_of?(Regexp::Expression::Base)},
      "Not all nodes are instances of Regexp::Expression")
  end


  def test_parse_node_types
    root = RP.parse('^(one){2,3}([^d\]efm-qz\,\-]*)(ghi)+$')

    assert( root.expressions[1].expressions[0].is_a?(Literal),
          "Not a literal node, but should be")

    assert( root.expressions[1].quantified?, "Not quanfified, but should be")

    assert( root.expressions[2].expressions[0].is_a?(CharacterSet),
          "Not a caracter set, but it should be")

    assert_equal( false, root.expressions[2].quantified? )

    assert( root.expressions[3].is_a?(Group::Capture),
          "Not a group, but should be")

    assert_equal( true, root.expressions[3].quantified? )
  end

  def test_parse_no_quantifier_target_raises_error
    assert_raise( ArgumentError ) { RP.parse('?abc') }
  end

  def test_parse_sequence_no_quantifier_target_raises_error
    assert_raise( ArgumentError ) { RP.parse('abc|?def') }
  end

end
