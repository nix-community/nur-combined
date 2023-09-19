#!/usr/bin/env ruby
require "paru/filter"

REPLACESTRING = "NEWLINE"
#REPLACESTRING2 = "\n\\newline\n"
REPLACESTRING2 = "&nbsp;\\\n"
Paru::Filter.run do

  with "Para" do |p|
    if p.inner_markdown.lines.length >= 1
      p.inner_markdown = REPLACESTRING + p.inner_markdown
    end
  end

  with "Header + 1 Para" do |p|
    p.inner_markdown = p.inner_markdown.gsub(REPLACESTRING,"")
  end

  with "Para" do |p|
    p.inner_markdown = p.inner_markdown.gsub(REPLACESTRING,REPLACESTRING2)
  end

end
