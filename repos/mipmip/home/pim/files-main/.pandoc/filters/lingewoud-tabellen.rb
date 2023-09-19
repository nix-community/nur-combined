#!/usr/bin/env ruby
require 'pp'
require "paru/filter"
require 'logger'
require 'tmpdir'


Paru::Filter.run do

  with "Table" do |t|
    data = t.to_array(headers: true)
    #p data
    #p t.headers

    tabel_type = "NORMAAL"

    ## IN DE 1e CEL VAN DE HEADER STAAT HET SOORT TABEL
    if data[0][0].include?('PRIJSTABEL2KOL')
      tabel_type = "PRIJSTABEL2KOL"
      data[0][0].gsub!('PRIJSTABEL2KOL','')
    end
    if data[0][0].include?('PRIJSTABEL3KOL')
      tabel_type = "PRIJSTABEL3KOL"
      data[0][0].gsub!('PRIJSTABEL3KOL','')
    end

    tex_table = []
    tex_table << "\\vspace{5mm}"
    tex_table << "\\setlength\\extrarowheight{5pt}"

    #FIRST LINE
    rowstr = "\\begin{tabular}{"
    first = true

    log = Logger.new File.open(File.join("/tmp", 'pandocerror.log'), 'w')
    log.level = Logger::INFO
#    log.error t.colspec.pretty_inspect
    log.error "hallo"


    t.colspec.each do |colspec|

      h_align = colspec.alignment

      if first && tabel_type == "PRIJSTABEL2KOL"
        rowstr << " | p{11cm}"
        first = false
      else
        if h_align.type == "AlignRight"
          rowstr << ' | r'
        else
          rowstr << ' | l'
        end
      end

    end
    rowstr << " | } \\hline"
    tex_table << rowstr
    log.error tex_table

    #SECOND LINE
    rowstr = ''
    data[0].each do |h_text|
      if rowstr == ''
        rowstr = "\\rowcolor{gray!20}"
      else
        rowstr << ' & '
      end
      rowstr << "\\bf{"+h_text+"}"
    end
    rowstr << "\\\\[5pt] \\hline"
    tex_table << rowstr

    #BODY LINES
    bidx = 0
    data.drop(1).each do |b_rows|
      rowstr = ''
      bidx+=1
      b_rows.each do | b_text |
        rowstr << " & " unless rowstr ==''
        if bidx==data.drop(1).length && tabel_type == "PRIJSTABEL2KOL"
          rowstr << "\\bf{"+b_text.to_s+"}"
        else
          rowstr << b_text.to_s
        end
      end
      rowstr << "\\\\[5pt] \\hline"
      tex_table << rowstr
    end

    #LAST LINE
    tex_table << "\\end{tabular}"
    tex_table << "\\vspace{5mm}"
    tex_table << ""

    t.parent.replace(t, Paru::PandocFilter::Node.from_markdown(tex_table.join("\n")))
  end

end

