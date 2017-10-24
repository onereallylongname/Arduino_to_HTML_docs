# encoding: Iso-8859-1

class FileCToHtml
  # Global Vars
  Version = "2.5"
  Help = "Reads .c, .cpp. ino, and maybe .js files. Looks for costum commentaries to write a html file.
          This file makes an index containing all the funtions in the file and links them to it's description.
          -v/-version   Version
          -h/-help      Help
          -i            Set input path
          -o            Set output path
          -e/-esp       Before a file that uses the Arduino esp8266 syntax"
          # -t            Set page title. Default \"Code functions\"" # not implemented
  FILE_TYPES = ['c', 'cpp', 'ino', 'js']
  LANGS = {:cLike => {'//1>' => :T1, '//2>' => :T2, '//3>' => :T3, 'args:' => :args, '//args:' => :args, 'rtrn:' => :rtrn, '//rtrn:' => :rtrn, 'dscr:' => :dscr, '//dscr:' => :dscr,
  '/***' => :startB, '***/' => :endB, '#include' => :incl}}
  TAGS_TRANSLATOR = {:p => 'p', :T1 => 'h1', :T2 => 'h2', :T3 => 'h2', :args => 'args', :rtrn => 'rtrn', :dscr => 'dscr'}
  TTLS = [:T1,:T2, :T3] # Title headers
  DESC = [:dscr, :args, :rtrn] # Code descriptors
  # CMNT = [:startC, :endC] # Comment identifier # '/*' => :startC, '*/' => :endC,
  BLCK = [:startB, :endB] # Comment Bloks


  def initialize argsIn
    # Return if no arguments where given
    if argsIn.empty?; puts "No valid args! Try -h"; return; end
    # Create hash with options
    @options = {:h => false, :v => false, :i => './', :o => './', :f => [], :e => []}
    # Process argv into options
    read_argv_flags argsIn
    # Check for version, help or if there are no files to run
    if @options[:v]; puts Version; return; end
    if @options[:h]; puts Help; return; end
    if @options[:f].empty?; puts 'Exit: file types not suported.'; return; end


    p @options
puts 'estou aqui'
#return  #TODO: retirar return

  # For each file, if it exists, read original and create html
    @options[:f].each do |name|
      if File.file?(make_path :i, name)
        lang = find_lang name
        puts"Reading: #{name}"
        readMyFile name, lang
        puts"Writing: #{name} to html"
        writeToMyFile name
      else
        puts  "File #{make_path :i,name} does not exist"
      end
    end
  end

private

  # Returns each file path
  def make_path inOut, name=''
    return @options[inOut] + '/' + name
  end
  # Turns argv command into symbol
  def strip_to_sym strIn
    return strIn[1].to_sym
  end
  # Checks file type against FILE_TYPES array
  def known_file_type fileName
    fileKnown = false
    fileType = fileName.split('.')[-1]
    FILE_TYPES.each { |ft| fileKnown |= fileType.eql? ft}
    return fileKnown
  end
  # Process argv into options
  def read_argv_flags argsIn
    skipVal = argsIn.length + 1
    argsIn.each_with_index do |argIn, ind|
      next if skipVal == ind
      arg = argIn.downcase()
      if arg[0].eql? '-'
        symAgr = strip_to_sym(arg)
        if @options[symAgr].is_a? String
          @options[symAgr] = argsIn[ind + 1]
          skipVal = ind + 1
        elsif @options[symAgr] == false
          @options[symAgr] = true
        elsif @options[symAgr].is_a? Array
          @options[symAgr] = argsIn[ind + 1]
        end
      elsif known_file_type arg
        @options[:f] << argIn.gsub(/(\.\/)|(\.\\)/,'')
      end
      puts argIn
    end
  end
  # Read css styles file
  def getStyle
    return File.read('css/style.css') if File.file?('css/style.css')
    raise "CSS file not found!"
  end
  # Creates output file name from original name
  def rename_out fileName
    name = fileName.split('/')[-1]
    name = name.split('\\')[-1]
   return "Code_From_#{name.gsub(/\./,'_')}.html"
  end
  # Displays progress in read stage.
  def disply_percente line, numLines, lastNum
    precenteDone = (line*100/numLines)
    print '0%' if line == 0
    print (" " + precenteDone.to_s + "%") if (precenteDone.ceil % 25 == 0 and precenteDone > 0) and lastNum.to_s != precenteDone.to_s
    print " ." if line%10 == 0
    puts '100%' if line == numLines-1
    newLastNum = precenteDone
    return (line += 1), newLastNum
  end

  def find_lang name
    case name.split('.')[-1].downcase
    when 'ino'
      return :cLike
    when 'c'
      return :cLike
    when 'cpp'
      return :cLike
    when 'js'
      return :cLike
    end
  end

  def addIncluds
    return "<h2 class=\"maincolor\"> Includes </h2>" + @includes + '<br>' if @includes != ""
    return ""
  end

  def text_tags line, lang
    textTags = nil
    keyLessLine = line
    LANGS[lang].keys.each do |marker|
      if keyLessLine.include? marker
        textTags = LANGS[lang][marker]
        keyLessLine.gsub!(marker, " ")
      end
      break if !textTags.nil?
    end
    keyLessLine.strip!
    textTags = ':p' if !keyLessLine.empty? and textTags.nil?
  return textTags, keyLessLine
  end

  def make_link lineContente, hashTagsFound
    link = (lineContente.gsub(/[^0-9A-Za-z\-_\/]/, '').downcase) + '0'
    while  hashTagsFound.include? link
      link[-1] = (link[-1].to_i + 1).to_s
    end
    return link
  end

  def addToSideBar lineContente, textTag, hashTagsFound
    link = make_link lineContente, hashTagsFound
    @sileSideBar = @sileSideBar + "<#{TAGS_TRANSLATOR[textTag]}> <a href=\"##{link}\"> #{lineContente}  </a> </#{TAGS_TRANSLATOR[textTag]}>"
    return link
  end

  def addToBody lineContente, textTag, link=nil, inBlock=0, inComment=false
    if TTLS.include? textTag
      @fileBody += "<#{TAGS_TRANSLATOR[textTag]} class=\"maincolor\"> <a name=\"#{link}\"> #{lineContente} </a></#{TAGS_TRANSLATOR[textTag]}><br>"
    elsif textTag == :incl
        @includes += "<font class=\"comment\">#{lineContente.gsub(/[^0-9A-Za-z\-_\/]/, '')}</font><br>"
    elsif inBlock
      if DESC.include? textTag
        @fileBody += "<font class=\"maincolor\">#{TAGS_TRANSLATOR[textTag]}</font>: #{lineContente}<br>"
      elsif BLCK.include? textTag
        inComment = !inComment
      elsif !BLCK.include? textTag
        if inComment
          @fileBody += "<font class=\"comment\">#{lineContente}</font><br>"
        else
          @fileBody += "#{lineContente}<br>"
        end
      end
    end
    return inComment
  end

  def find_block textTag, inBlock
    inBlock = true if BLCK[0] == textTag
    inBlock = false if BLCK[1] == textTag
    return inBlock
  end

  def readMyFile fileName, lang
    numLines = File.foreach(make_path( :i, fileName)).count
    hashTagsFound = []
    lineCounter = 0
    precenteDone = 0
    counter = 0
    inBlock = 0
    inComment = false
    lastNum = 0;
    @sileSideBar = ""
    @webUrl = ""
    @urlNumber = 0
    @fileBody = ""
    @includes = ""
    esp = false
    @fileBody = ""
    if @options[:e].include? fileName
      @sileSideBar = "<a href=\"#aurl\"> Avaliable url </a> <br>"
      @webUrl = "<a name=\"aurl\" <h3 class=\"maincolor\"> Avaliable url: </h3> </a> <br> "
      @urlNumber = 0
      esp = true
      puts 'Mode: esp on.'
    end
    file = File.new(make_path( :i, fileName), "r:Iso-8859-1")
    while (line = file.gets)
      lineCounter, lastNum = disply_percente lineCounter, numLines, lastNum
      textTags, lineContente = text_tags line, lang
      inBlock = find_block textTags, inBlock
 # p lineCounter
 # p textTags
# p keyLessLine
 #system('pause')
# next

      if TTLS.include? textTags
          link = addToSideBar lineContente, textTags, hashTagsFound
          hashTagsFound << link
      end
      inComment = addToBody lineContente, textTags, link, inBlock, inComment
    end
    file.close
    @sileSideBar = @sileSideBar + "<br> <br>"
    puts 'Done (1/2)'
  end
=begin
      if a.eql? "//>>"
        counter = 2
        headerc = true
      end
      nameTag = ""
      if headerc
        headeropen  = ""
        headerClose = ""
        nameTag = line[4..-1].gsub(/[^0-9A-Za-z\-_]/, '')
        if nameTag.include? "------"
          headeropen  = "<br>"
        end
        if firstFunc
          headeropen  = "<br>"
          nameTag = nameTag.upcase
        end
        @sileSideBar = @sileSideBar + "<a href=\"##{nameTag.downcase}\">" + headeropen + nameTag + "</h4> <br> </a>"
        firstFunc = false
      end
      if counter > 0
        if headerc
          @fileBody = @fileBody + "<br><p> <a name=\"#{nameTag.downcase}\"> <p class=\"maincolor\">" + line[4..-1].chomp + " </p>"
          headerc = false
        elsif a.eql? "/***" or a.eql? "****"
            counter -= 1
        elsif line.split(' ')[0].eql? "args:" or line.split(' ')[0].eql? "dscr:" or line.split(' ')[0].eql? "rtrn:"
          @fileBody = @fileBody + "<font class=\"maincolor\">" + line.split(' ')[0] + "</font>" + line[6..-1].chomp + "<br>"
        elsif line.include? "/*" or line.include? "*/"
          @fileBody = @fileBody + "<font class=\"maincolor\">" + line + "</font> <br>"
        else
          @fileBody = @fileBody + line + "<br>"
        end
         @fileBody = @fileBody + "</p>" if counter == 0
      end
      #check server.on functions
      if line.include? "server.on("
        @urlNumber += 1
        splitLine = line.split(/[\s(),]/).delete_if { |var| var.eql? ""}
        @webUrl = @webUrl + "<a href=\"##{splitLine[-2].downcase}\" class=\"espurlcolor\" >" + splitLine[1] +  "</a> ; "
        @webUrl = @webUrl + "<br>" if @urlNumber % 10 == 0
      end
    end
=end

  def writeToMyFile fileName
    codeFileNewname = rename_out fileName
    style = getStyle
    #TODO: refactor header (create function)
    htmlHeader = "<!DOCTYPE html> <html> <head> <title> #{codeFileNewname.split('.')[0]} </title> <style> #{style} </style> </head>"
    htmlBody = "<body> <div id=\"content\"> <div id=\"sidebar\"> <div id=\"innersidebar\"> <h2> Contents </h2> <br>" + @sileSideBar + "</div></div> <div id=\"main\"> <div id=\"maininnerdiv\"> <div class=\"container\" id=\"title\"> <h1 class=\"maincolor\"> #{codeFileNewname.split('.')[0]} </h1> <font class=\"maincolor\"> (Version: " + Time.now.to_s  + ") </font> </div> <div class=\"container\" id=\"main1\"> <br> " + @webUrl + addIncluds + @fileBody + " </div> </div></div> </div> <footer> <p>Code By: AA @ <a href=\"https://github.com/onereallylongname\"> github</a></p></footer> </body> </html>"
    File.write(make_path(:o) + codeFileNewname, htmlHeader + htmlBody)
    puts "Done (2/2): #{codeFileNewname}"
  end

end

FileCToHtml.new(ARGV)
