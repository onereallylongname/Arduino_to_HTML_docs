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

  def initialize argsIn
    if argsIn.empty?; puts "No valid args! Try -h"; return; end
    @classObj = self
    @options = {:h => false, :v => false, :i => './', :o => './', :f => []}

    read_argv_flags argsIn

    if @options[:v]; puts Version; return; end
    if @options[:h]; puts Help; return; end
    if @options[:f].empty?; puts 'Exit: file types not suported.'; return; end


    p @options

    # case option
    #
    # when condition
    #
    # end
puts 'estou aqui'
#return  #TODO: retirar return
  #  @readFileNameArray = []
  #  argsIn.each { |names| @readFileNameArray.push(names.to_s) }

    #TODO: make it run once
    @fileCode = ""
    @knownFunctions = []
    @fileHeader = "<a href=\"#aurl\"> Avaliable url </a> <br>"
    @webUrl = "<a name=\"aurl\" <h3 style=\"color: #ff9933\"> Avaliable url: </h3> </a> <br> "
    @urlNumber = 0

    @options[:f].each do |name|
      if File.file?(make_path :i, name)
        puts"Reading: #{name}"
        readMyFile name
        puts"Writing: #{name} to html"
        writeToMyFile name
      else
        puts  "File #{make_path :i,name} does not exist"
      end
    end
  end

private

  def make_path inOut, name=''
    return @options[inOut] + '/' + name
  end

  def strip_to_sym strIn
    return strIn[1].to_sym
  end

  def known_file_type fileName
    fileKnown = false
    fileType = fileName.split('.')[-1]
    FILE_TYPES.each { |ft| fileKnown |= fileType.eql? ft}
    return fileKnown
  end

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

  def getStyle
    return File.read('css/style.css') if File.file?('css/style.css')
    raise "CSS file not found!"
  end

  def rename_out fileName
    name = fileName.split('/')[-1]
    name = name.split('\\')[-1]
   return "Code_From_#{name.gsub(/\./,'_')}.html"
  end

  def disply_percente line, numLines
    precenteDone = (line*100/numLines).to_i
    print (" " + precenteDone.to_s + "%") if (precenteDone % 25 == 0 and precenteDone > 0)
    print " ." if line%10 == 0
    return (line += 1)
  end

#TODO: refactor readMyFile
  def readMyFile fileName
    numLines = File.foreach(make_path( :i, fileName)).count
    lineCounter = 0
    precenteDone = 0
    counter = 0
    headerc = false
    firstFunc = true
    file = File.new(make_path( :i, fileName), "r:Iso-8859-1")
    while (line = file.gets)
      lineCounter = disply_percente lineCounter, numLines
      a = line[0..3]
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
        @knownFunctions.push(nameTag.downcase)
        @fileHeader = @fileHeader + "<a href=\"##{nameTag.downcase}\">" + headeropen + nameTag + "</h4> <br> </a>"
        firstFunc = false
      end
      if counter > 0
        if headerc
          @fileCode = @fileCode + "<br><p> <a name=\"#{nameTag.downcase}\"> <p style=\"color: #ff9933\"> <font size=\"4\">" + line[4..-1].chomp + "</font> </p>"
          headerc = false
        elsif a.eql? "/***" or a.eql? "****"
            counter -= 1
        elsif line.split(' ')[0].eql? "args:" or line.split(' ')[0].eql? "dscr:" or line.split(' ')[0].eql? "rtrn:"
          @fileCode = @fileCode + "<font color=\"#ff9933\">" + line.split(' ')[0] + "</font>" + line[6..-1].chomp + "<br>"
        elsif line.include? "/*" or line.include? "*/"
          @fileCode = @fileCode + "<font color=\"#b3bfcc\">" + line + "</font> <br>"
        else
          @fileCode = @fileCode + line + "<br>"
        end
         @fileCode = @fileCode + "</p>" if counter == 0
      end
      #check server.on functions
      if line.include? "server.on("
        @urlNumber += 1
        splitLine = line.split(/[\s(),]/).delete_if { |var| var.eql? ""}
        @webUrl = @webUrl + "<a href=\"##{splitLine[-2].downcase}\" style=\"color: #990000\" >" + splitLine[1] +  "</a> ; "
        @webUrl = @webUrl + "<br>" if @urlNumber % 10 == 0
      end
    end
    file.close
    @fileCode = @fileCode + "<br> <font color=\"#ff9933\"> - - - - - \"\" - - - - - </font> <br>"
    @fileHeader = @fileHeader + "<br> <br>"
    puts 'Done (1/2)'
  end

  def writeToMyFile fileName
    codeFileNewname = rename_out fileName
    puts codeFileNewname
    style = getStyle
    #TODO: refactor header (create function)
    htmlHeader = "<!DOCTYPE html>\n <html>\n    <head>\n      <style>\n#{style}\n      </style>\n    </head>"
    htmlBody = "<body> <div id=\"content\"> <div id=\"sidebar\"> <h2 style=\"color:white\"> Contents </h2>" + @fileHeader + "</div> <div id=\"main\"> <div class=\"container\" id=\"title\"> <h1 style=\"color: #ff9933\"> Code functions </h1> <font color=\"#ff9933\"> (Version: " + Time.now.to_s  + ") </font> </div> <div class=\"container\" id=\"main1\"> <br> "  + @webUrl + @fileCode + " </div> </div> </div> <footer> <p>Code By: AA @ <a href=\"https://github.com/onereallylongname\"> github</a></p></footer> </body> </html>"
#TODO: change output dir
    File.write(make_path(:o) + codeFileNewname, htmlHeader + htmlBody)
    puts " Done (2/2)!"
  end

end

FileCToHtml.new(ARGV)
