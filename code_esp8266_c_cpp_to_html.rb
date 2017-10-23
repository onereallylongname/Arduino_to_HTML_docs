# encoding: Iso-8859-1

class FileCToHtml
  # Global Vars
  Version = "2.5"
  Help = "Reads .c, .cpp. ino, and maybe .js files. Looks for costum commentaries to write a html file.
          This file makes an index containing all the funtions in the file and links them to it's description.
          -v/-version   Version
          -h/-help      Help
          -i            Set input path
          -o            Set output path"
  FILE_TYPES = ['c', 'cpp', 'ino', 'js']
  LANGS = {:cLike => {'//>' => :T1, '//>>' => :T2, '//>>>' => :T3, 'args' => :args, '//args' => :args,
                      'rtrn' => :rtrn, '//rtrn' => :rtrn, 'dscr' => :dscr, '//dscr' => :dscr,
                      '/****' => :startC, '****' => :endC}}

  TAGS_TRANSLATOR = {:T1 => 'h1', :T2 => 'h3', :T3 => 'h5', :args => 'args', :rtrn => 'rtrn', :dscr => 'dscr'}

  def initialize argsIn
    # Return if no arguments where given
    if argsIn.empty?; puts "No valid args! Try -h"; return; end
    # Create hash with options
    @options = {:h => false, :v => false, :i => './', :o => './', :f => []}
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
  def disply_percente line, numLines
    precenteDone = (line*100/numLines).to_i
    print (" " + precenteDone.to_s + "%") if (precenteDone % 25 == 0 and precenteDone > 0)
    print " ." if line%10 == 0
    return (line += 1)
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

  def text_tag marker, lang
    return 'p' if TAGS_TRANSLATOR[LANGS[lang][marker.strip]].nil?
    return TAGS_TRANSLATOR[LANGS[lang][marker.strip]]
  end

  def find_line_content line
    return line[4..-1].gsub(/[^0-9A-Za-z\-_]/, '')
  end

  def addToSideBar lineContente, textTag
    @sileSideBar += "<#{textTag}> <a href=\"##{lineContente.downcase}\"> #{lineContente}  </a> </#{textTag}> <br>"
  end

  def addToBody lineContente, textTag, header=false
    if header
      @sileSideBar = "<#{textTag}> <a href=\"##{nameTag.downcase}\"> #{nameTag}</a><#{textTag}>"
    else
#TODO: copy add to body
    end
  end

#TODO: refactor readMyFile
  def readMyFile fileName, lang
    numLines = File.foreach(make_path( :i, fileName)).count
    hashTagsFound = []
    @fileBody = ""
    @sileSideBar = "<a href=\"#aurl\"> Avaliable url </a> <br>"
    @webUrl = "<a name=\"aurl\" <h3 class=\"maincolor\"> Avaliable url: </h3> </a> <br> "
    @urlNumber = 0
    lineCounter = 0
    precenteDone = 0
    counter = 0
    headerc = false
    firstFunc = true

    localOptions = {}

    file = File.new(make_path( :i, fileName), "r:Iso-8859-1")


    while (line = file.gets)

      lineCounter = disply_percente lineCounter, numLines


      a = line[0..4]

      textTag = text_tag line[0..4], lang

p textTag if textTag != 'p'

      if [:T1, :T2, :T3].include? textTag
        counter = 2
        lineContente = find_line_content line
        addToSideBar lineContente, textTag
        addToBody lineContente, textTag







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
    file.close
    @fileBody = @fileBody + "<br> <font class=\"maincolor\"> - - - - - \"\" - - - - - </font> <br>"
    @sileSideBar = @sileSideBar + "<br> <br>"
    puts 'Done (1/2)'
  end

  def writeToMyFile fileName
    codeFileNewname = rename_out fileName
    puts codeFileNewname
    style = getStyle
    #TODO: refactor header (create function)
    htmlHeader = "<!DOCTYPE html>\n <html>\n    <head>\n      <style>\n#{style}\n      </style>\n    </head>"
    htmlBody = "<body> <div id=\"content\"> <div id=\"sidebar\"> <h2 class=\"sidecolor\"> Contents </h2>" + @sileSideBar + "</div> <div id=\"main\"> <div class=\"container\" id=\"title\"> <h1 class=\"maincolor\"> Code functions </h1> <font class=\"maincolor\"> (Version: " + Time.now.to_s  + ") </font> </div> <div class=\"container\" id=\"main1\"> <br> "  + @webUrl + @fileBody + " </div> </div> </div> <footer> <p>Code By: AA @ <a href=\"https://github.com/onereallylongname\"> github</a></p></footer> </body> </html>"
    File.write(make_path(:o) + codeFileNewname, htmlHeader + htmlBody)
    puts " Done (2/2)!"
  end

end

FileCToHtml.new(ARGV)
