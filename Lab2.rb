require 'set'

class NFARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}"
  end
end

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character) }.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
  end

  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end
end


if __FILE__ == $0
  rulebook = NFARulebook.new([
                                 NFARule.new(1, 'a', 1), NFARule.new(1, 'b', 1),
                                 NFARule.new(1, 'b', 2), NFARule.new(2, 'a', 3),
                                 NFARule.new(2, 'b', 3), NFARule.new(3, 'a', 4),
                                 NFARule.new(3, 'b', 4)
                             ])
  nfa_design = NFADesign.new(1, [4], rulebook)
  puts nfa_design.accepts?('bab')
  puts nfa_design.accepts?('bbbbb')
  puts nfa_design.accepts?('bbabb')
end