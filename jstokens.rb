# This script converts a javascript file into a list-of-words

$comment_single_re = /\/\/(.*)?/
$comment_multi_re  = /\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//
$whitespace_re     = /\s+/
$symbols_re        = /([\$_a-zA-Z][\$_a-zA-Z0-9]+)/

class String
  def remove_comments
    gsub($comment_multi_re, ' ').gsub($comment_single_re, ' ')
  end

  def normalize_whitespace
    gsub($whitespace_re, ' ')
  end

  def symbols_only
    scan($symbols_re).join(" ")
  end
end

ARGV.each do |filename|
  if File.file?(filename)
    text = File.read(filename)
      .encode('UTF-8', 'binary',
        invalid: :replace,
        undef: :replace,
        replace: ''
      )
    puts text.remove_comments.symbols_only
  else
    $stderr.puts "Skipping #{filename} (not a file)"
  end
end
