bible = File.read("kjv.json").upcase.gsub(/[^a-zA-Z ]/, ' ')

# Clean text: replace non-letters with space, then split and reject empty
text = bible.gsub(/[^A-Z ]/, ' ')
words = text.split.reject(&:empty?)

# Simple function for words (length 1) appearing exactly c times
def find_words_by_count(words, c)
  words.
    group_by { |x| x }.
    map { |word, list| [word, list.count] }.
    select { |_, count| count == c }.
    sort_by { |word, _| word }.
    map(&:first)
end

# Example: all words appearing exactly once
# hapax_words = find_words_by_count(words, 1)

require 'set'

# New function: find all unique phrases (1 to max_length words) that appear exactly once
def find_hapax_phrases(words, max_length = 10)
  return [] if max_length < 1
  
  n = words.length
  seen = Set.new
  hapax = Set.new
  
  # Sliding window over all possible starting positions and lengths
  (1..max_length).each do |len|
    (0..n - len).each do |start|
      phrase = words[start, len].join(' ')
      if seen.add?(phrase)
        # First time seen in this pass
        hapax.add(phrase)
      else
        # Seen before -> not hapax, ensure removed if previously added
        hapax.delete(phrase)
      end
    end
  end
  
  # Sort first by length (ascending), then alphabetically
  result = hapax.to_a.sort_by { |p| [p.split.size, p] }
  
  # Optional: save to file
  p result.join("\n") + "\n"
  File.write("hapax_phrases_up_to_#{max_length}.txt", result.join("\n") + "\n")
  
  result
end

# Example usage:
# For only unique words (equivalent to find_words_by_count(words,1)):
#find_hapax_phrases(words, 1)

# For phrases up to 5 words long that appear exactly once:
find_hapax_phrases(words, 5)

# For longer phrases, increase the limit (memory-intensive for large max_length)
# Bible has ~800k words, so max_length=10 is feasible (~8 million phrases)
# max_length=20 would be ~16 million, still ok on modern machines, but slower