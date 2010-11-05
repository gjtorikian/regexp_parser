# A very thin wrapper around the scanner that breaks quantified literal runs,
# collects emitted tokens into an array, calculates their nesting depth, and
# normalizes tokens for the parser, and checks if they are implemented by the
# given syntax flavor.
module Regexp::Lexer

  # TODO: complete, test token sets
  OPENING_TOKENS = [:open, :capture, :options].freeze
  CLOSING_TOKENS = [:close].freeze

  def self.scan(input, syntax = 'ruby/1.9', &block)
    syntax = Regexp::Syntax.new(syntax)

    @tokens = []
    @nesting = 0

    last = nil
    Regexp::Scanner.scan(input) do |type, token, text, ts, te|
      type, token = *syntax.normalize(type, token)
      syntax.check! type, token

      @nesting -= 1 if CLOSING_TOKENS.include?(token)

      self.break_literal(last) if type == :quantifier and
        last and last.type == :literal

      current = Regexp::Token.new(type, token, text, ts, te, @nesting)

      current = self.merge_literal(current) if type == :literal and
        last and last.type == :literal

      last.next(current) if last
      current.previous(last) if last

      @tokens << current
      last = current

      @nesting += 1 if OPENING_TOKENS.include?(token)
    end

    if block_given?
      @tokens.each {|token| yield token}
    else
      @tokens
    end
  end

  # called by scan to break a literal run that is longer than one character
  # into two separate tokens when it is followed by a quantifier
  def self.break_literal(token)
    text = token.text
    if text.scan(/./mu).length > 1
      lead = text.sub(/.\z/mu, "")
      last = text[/.\z/mu] || ''

      @tokens.pop
      @tokens << Regexp::Token.new(:literal, :literal, lead, token.ts,
                                   (token.te - last.length), @nesting)

      @tokens << Regexp::Token.new(:literal, :literal, last,
                                   (token.ts + lead.length),
                                   token.te, @nesting)
    end
  end

  # called by scan to merge two consecutive literals. this happens when tokens
  # get normalized (as in the case of posix/bre) and end up becoming literals.
  def self.merge_literal(current)
    last = @tokens.pop

    replace = Regexp::Token.new(:literal, :literal, last.text + current.text,
                                   last.ts, current.te, @nesting)
  end

end # module Regexp::Lexer