require_relative 'project'

module Swift
  def parse_file(path, project)
    file = File.read(path)
    if file.valid_encoding?
      return ProjectFile.new(raw_lines=file.split("\n"), path, project)
    end
    return nil
  end

  module Publicity
    PUBLIC = 'public'
    PRIVATE = 'private'
    INTERNAL = 'internal'

    OPEN = 'open'
  end

  module Usability
    CLASS = 'class'
    STATIC = 'static'

    FINAL = 'final'

    CONVENIENCE = 'convenience'
    REQUIRED = 'required'
  end

  module CodeLineType
    IMPORT = 'import'

    CLASS = 'class'
    PROTOCOL = 'protocol'
    EXTENSION = 'extension'
    STRUCT = 'struct'
    ENUM = 'enum'


    LET = 'let'
    VAR = 'var'

    FUNC = 'func'

    IBOUTLET = '@IBOutlet'
    IBACTION = '@IBAction'

    def line_type(raw_line)
      for type in Swift::CodeLineType
        if line_is_type(type, raw_line)
          return type
        end
      end
      return None
    end

    module_function
    def line_is_type(type, raw_line)
      return (raw_line =~ /(?<=\s)*(?<!\S)+(#{type})(?=\s)/) != nil
    end
  end

  class Stats
    attr_accessor :import_count, :class_count, :protocol_count, :extension_count,
                  :struct_count, :enum_count,
                  :let_count, :var_count, :func_count, :ibaction_count, :iboutlet_count,
                  :public_count, :private_count, :internal_count, :open_count

    def initialize(file)
      @file = file

      @import_count = @file.lines_of_types([Swift::CodeLineType::IMPORT]).count

      @class_count = @file.lines_of_types([Swift::CodeLineType::CLASS]).count
      @protocol_count = @file.lines_of_types([Swift::CodeLineType::PROTOCOL]).count
      @extension_count = @file.lines_of_types([Swift::CodeLineType::EXTENSION]).count
      @struct_count = @file.lines_of_types([Swift::CodeLineType::STRUCT]).count
      @enum_count = @file.lines_of_types([Swift::CodeLineType::ENUM]).count

      @let_count = @file.lines_of_types([Swift::CodeLineType::LET]).count
      @var_count = @file.lines_of_types([Swift::CodeLineType::VAR]).count

      @func_count = @file.lines_of_types([Swift::CodeLineType::FUNC]).count

      @ibaction_count = @file.lines_of_types([Swift::CodeLineType::IBACTION]).count
      @iboutlet_count = @file.lines_of_types([Swift::CodeLineType::IBOUTLET]).count

      @public_count = @file.lines_of_types([Swift::Publicity::PUBLIC]).count
      @private_count = @file.lines_of_types([Swift::Publicity::PRIVATE]).count
      @internal_count = @file.lines_of_types([Swift::Publicity::INTERNAL]).count
      @open_count = @file.lines_of_types([Swift::Publicity::OPEN]).count
    end

    def count_of_types(types)
      return @file.lines_of_types(types).count
    end
  end

  class ProjectFile < Project::CodeFile
    def initialize(raw_lines, path, project)
      super(raw_lines, path, project)
      @CodeLineType = Swift::CodeLineType
    end
  end

  module_function :parse_file
end
