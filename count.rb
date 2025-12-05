bible = File.read("kjv.json").upcase.gsub(/[^a-zA-Z ]/, '')

def find_words_by_count(text,c)
    text.
    split(" ").
    upcase.
    gsub(/[^a-zA-Z ]/, '').
    split(" ").
    group_by{|x| x}.
    map{|x| [x[0],x[1].count]}.
    filter{|x| x[1] == c}.
    sort_by{|x| x[0]}
end
#p find_words_by_count(bible,49)

require 'set'

def suffix_array(words)
  n = words.length
  return [] if n == 0
  
  # Assign initial ranks to words
  unique_words = words.uniq.sort
  word_to_rank = Hash[unique_words.each_with_index.to_a]
  rank = words.map { |w| word_to_rank[w] }
  
  sa = (0...n).to_a
  k = 1
  while k < n
    sa.sort! do |x, y|
      rx1 = rank[x]
      ry1 = rank[y]
      if rx1 != ry1
        rx1 <=> ry1
      else
        rx2 = (x + k < n) ? rank[x + k] : -1
        ry2 = (y + k < n) ? rank[y + k] : -1
        rx2 <=> ry2
      end
    end
    tmp = Array.new(n, 0)
    tmp[sa[0]] = 0
    (1...n).each do |i|
      prev = sa[i - 1]
      curr = sa[i]
      pr1 = rank[prev]
      cr1 = rank[curr]
      pr2 = (prev + k < n) ? rank[prev + k] : -1
      cr2 = (curr + k < n) ? rank[curr + k] : -1
      if [pr1, pr2] != [cr1, cr2]
        tmp[curr] = tmp[prev] + 1
      else
        tmp[curr] = tmp[prev]
      end
    end
    rank = tmp
    k *= 2
  end
  sa
end

def lcp_array(words, sa)
  n = words.length
  rank = Array.new(n, 0)
  sa.each_with_index { |pos, i| rank[pos] = i }
  lcp = Array.new(n, 0)
  h = 0
  (0...n).each do |i|
    if rank[i] == 0
      h = 0
      next
    end
    j = sa[rank[i] - 1]
    while i + h < n && j + h < n && words[i + h] == words[j + h]
      h += 1
    end
    lcp[rank[i]] = h
    h = [h - 1, 0].max
  end
  lcp
end

def build_sparse_table(arr)
  n = arr.length
  logn = Math.log2(n).floor + 1
  st = Array.new(logn) { Array.new(n) }
  n.times { |i| st[0][i] = arr[i] }
  (1...logn).each do |k|
    n.times do |i|
      j = 1 << (k - 1)
      if i + j < n
        st[k][i] = [st[k - 1][i], st[k - 1][i + j]].min
      else
        st[k][i] = st[k - 1][i]
      end
    end
  end
  st
end

def range_min(st, left, right)
  return Float::INFINITY if left > right
  len = right - left + 1
  k = Math.log2(len).floor
  j = 1 << k
  [st[k][left], st[k][right - j + 1]].min
end

def find_repeating_word_phrases(text, y)
  return [] if y < 2 || text.empty?
  words = text.split(/\s+/).reject(&:empty?)
  n = words.length
  return [] if n < y
  
  sa = suffix_array(words)
  lcp = lcp_array(words, sa)
  st = build_sparse_table(lcp)
  result = Set.new
  (0...n - y + 1).each do |i|
    left_idx = i + 1
    right_idx = i + y - 1
    min_lcp_val = range_min(st, left_idx, right_idx)
    left_lcp = i == 0 ? 0 : lcp[i]
    right_lcp = i + y == n ? 0 : lcp[i + y]
    start_m = [left_lcp, right_lcp].max + 1
    if start_m <= min_lcp_val
      pos = sa[i]
      (start_m..min_lcp_val).each do |m|
        phrase = words[pos, m].join(' ')
        result.add(phrase)
      end
    end
  end
  result = result.to_a.sort
  File.write("repeating_phrases_y#{y}.txt", result.join("\n") + "\n")
  result
end

p find_repeating_word_phrases(bible,49)
