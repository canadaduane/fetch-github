# This script converts a javascript file into a list-of-words

$multiline_comment_re = /\/\*![^*]*\*+(?:[^*\/][^*]*\*+)*\//

class String
  def remove_comments
    gsub($multiline_comment_re, ' ')
  end

  def normalize_whitespace
    gsub(/\s+/, ' ')
  end

  def symbols_only
    scan(/([\$_a-zA-Z][\$_a-zA-Z0-9]+)/).join(" ")
  end
end

ARGV.each do |filename|
  text = File.read(filename)
  puts text.remove_comments.symbols_only
end
