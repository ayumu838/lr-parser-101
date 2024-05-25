class Calc

preclow
  left '.' '='
  left '+' '-'
  left '*' '/'
  left '^'
prechigh

rule
  program: expr { p "result is #{result.nil? ? 'nil' : result}" }
         ;

  expr  : expr '+' expr  { result = val[0] + val[2] }
        | expr '-' expr  { result = val[0] - val[2] }
        | expr '*' expr  { result = val[0] * val[2] }
        | expr '/' expr  { result = val[0] / val[2] }
        | expr '^' expr  { result = val[0] ** val[2] }
        | '(' expr ')'   { result = val[1] }
        | val            { result = val[0] }
        | num            { result = val[0] }
        ;

    num : '-' num_token { result = - val[1] }
        | '+' num_token { result = val[1] }
        | num_token   { result = val[0] }
        ;

    num_token : INTEGER { result = val[0] }
              | FLOAT   { result = val[0] }
              ;

  val: VAL '=' expr { @variables[val[0].to_s] = val[2]; result = val[2] }
     | VAL          { result = @variables[val[0].to_s] }
     ;
end

---- header
# header

require 'strscan'

---- inner
# inner

  def parse(str)
    @q = []
    ss = StringScanner.new(str)

    @variables ||= {}
    while !ss.eos? do
      case
      when ss.scan(/\s+/)
        # skip spaces
      when ss.scan(/((\d+_)*\d+\.\d+|\d+\.\d+)/)
        @q << [:FLOAT, ss[0].to_f]
      when ss.scan(/((\d+_)*\d+)/)
        @q << [:INTEGER, ss[0].to_i]
      when ss.scan(/\+/)
        @q << ['+', '+']
      when ss.scan(/\-/)
        @q << ['-', '-']
      when ss.scan(/\*/)
        @q << ['*', '*']
      when ss.scan(/\//)
        @q << ['/', '/']
      when ss.scan(/\(/)
        @q << ['(', '(']
      when ss.scan(/\)/)
        @q << [')', ')']
      when ss.scan(/\./)
        @q << ['.', '.']
      when ss.scan(/\^/)
        @q << ['^', '^']
      when ss.scan(/([a-zA-Z_]\w*)/)
        @q << [:VAL, ss[0]]
      when ss.scan(/=/)
        @q << ['=', '=']
      else
        raise "Parse error (unknown token): #{ss.string[ss.pos]} (#{ss.string}, #{ss.pos})"
      end
    end

    @q << [false, '$end']
    @test = @q.dup
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer
# footer

parser = Calc.new

while true do
  puts "Enter the formula:\n"
  str = gets.chomp

  if /\Aq/i =~ str
    puts "Bye!\n"
    exit
  end

  begin
    parser.parse(str)
  rescue => e
    puts e
  end

  puts "\n"
end
