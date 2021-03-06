module Regexp::Syntax

  module Ruby
    class V186 < Regexp::Syntax::Base
      include Regexp::Syntax::Token

      def initialize
        super

        implements :anchor, Anchor::All
        implements :assertion, Assertion::Lookahead
        implements :backref, [:number]

        implements :escape,
          Escape::Basic + Escape::Backreference +
          Escape::ASCII + Escape::Meta + Escape::Control

        implements :group, Group::All

        implements :meta, Meta::Extended

        implements :quantifier,
          Quantifier::Greedy + Quantifier::Reluctant +
          Quantifier::Interval + Quantifier::IntervalReluctant

        implements :set, CharacterSet::OpenClose +
          CharacterSet::Extended + CharacterSet::Types +
          CharacterSet::POSIX::Standard

        implements :type,
          CharacterType::Extended
      end

    end
  end

end
