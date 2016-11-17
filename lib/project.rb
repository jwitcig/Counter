module Project
  class Project
    attr_accessor :name

    def initialize(name)
      @name = name
    end
  end

  class CodeFile
    attr_accessor :raw_lines
    attr_accessor :lines
    attr_accessor :blocks

    def initialize(raw_lines)
      @raw_lines = raw_lines
      @blocks = find_brace_pairs
      @lines = generate_line_items
    end

    def line_range
      return 0, line_count
    end

    def line_count
      return @raw_lines.count
    end

    def lines_of_types(types, range=nil)
      if range.nil?
        range = line_range
      end
      return @lines.select { |x|
        types.inject(true) { |is_match, type|
          is_match ? @CodeLineType.line_is_type(type, x.raw) : false
        }
      }
    end

    def top_level_blocks
      return @blocks.comprehend { |x|
        x if x.parent_block?
      }
    end

    def find_brace_pairs
      raw_lines = @raw_lines
      bracket_blocks = []

      open_brackets = []
      raw_lines.each_with_index do |line, index|
        bracket_index = line.index('{')
        if bracket_index != -1
          open_brackets.push(line, index)
        end

        if line.index('}') != -1
          (open_line, open_line_index) = open_brackets[-1]
          open_brackets.pop
          bracket_blocks.push(BracketBlock.new(open_line_index, index, self))
        end
      end
      return bracket_blocks
    end

    def white_lines_count
      return @lines.select { |x| x.is_white_line }.count
    end

    def clean
      @raw_lines = @lines.comprehend { |x|
        x.raw if not x.is_white_line
      }
      @lines = generate_line_items
    end

    def generate_line_items
      return @raw_lines.map { |x| LineItem.new(x) }
    end
  end

  class BracketBlock
    attr_accessor :first_line_index
    attr_accessor :last_line_index
    attr_accessor :file

    def initialize(first_line_index, last_line_index, file)
      @first_line_index = first_line_index
      @last_line_index = last_line_index
      @file = file
    end

    def raw_lines
      return @file.raw_lines[first_line_index:last_line_index]
    end

    def lines
      return @file.lines[first_line_index:last_line_index]
    end

    def line_range
      return Tuple(@first_line_index, last_line_index)
    end

    def first_line
      return @file.lines[first_line_index]
    end

    def last_line
      return @file.lines[last_line_index]
    end

    def lines_of_type(type)
      return @file.lines_of_type(type, range=line_range)
    end

    def owned_lines
      owned_blocks = contained_blocks.comprehend { |x| x if x.parent_block == self }

      parent_interval_set = IntervalSet(Interval(line_range[0], line_range[-1]))
      child_intervals_set = IntervalSet(owned_blocks.comprehend { |x|
        Interval(x.line_range[0], x.line_range[-1])
      })
      return parent_interval - child_intervals_set
    end

    def contained_blocks
      blocks = @file.blocks.comprehend { |x| x if range_contains(line_range, x)}
      return blocks.sort
    end

    # @property
    # def contained_blocks(self):
    #     contained_blocks = []
    #     for block in self.file.blocks:
    #         child_block_line_range = range(block.first_line_index, block.last_line_index)
    #
    #         if range_contains(self.line_range, child_block_line_range):
    #             contained_blocks.append(block)
    #     return contained_blocks

    def parent_block
      potential_blocks = @file.blocks.comprehend { |x| x if x != self}
      return potential_blocks.comprehend { |x|
        x if range_contains(x.line_range, line_range)
      }[-1]
    end

    def open_brace_index
      return @first_line.find('{')
    end

    def close_brace_index
      return @last_line.find('}')
    end
  end

  class LineItem
    attr_accessor :raw

    def initialize(raw_line)
      @raw = raw_line
    end

    def is_white_line
      if @raw.length == 0
        return true
      end
      return @raw.blank?
    end

    def split_line_into_words(line)
      replacables = [
        Tuple('<', ' < '),
        Tuple('>', '> '),
        Tuple(':', ' : '),
        Tuple('{', ''),
        Tuple('}', ''),
      ]

      for removable, replacable in replacables
        line = str.replace(line, removable, replacable)
      end
      return line.split()
    end
  end
end
