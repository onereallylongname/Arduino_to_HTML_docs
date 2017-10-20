# encoding: Iso-8859-1

class FileCToHtml
  Version = "2.0" # read multiple files
  Help = "Reads files and looks for my headrs and de \"server.on\" command to write a html file.
          -v/-version Version
          -h/-help Help
          Files will appear in the order of the arguments
          Note: This code was created to work with arduino esp8266 code!"

  def initialize argsIn
    if argsIn.empty?; puts "No valid args! Try -h"; return; end
    if argsIn[0].eql? "-v" or argsIn[0].eql? "-version"; puts Version; return; end
    if argsIn[0].eql? "-h" or argsIn[0].eql? "-help"; puts Help; return; end

    @readFileNameArray = []
    argsIn.each { |names| @readFileNameArray.push(names.to_s) }

    @readFileName1 = @readFileNameArray[0]
    @fileCode = ""
    @knownFunctions = []
    @fileHeader = "<a href=\"#aurl\"> Avaliable url </a> <br>"
    @webUrl = "<a name=\"aurl\" <h3 style=\"color: #ff9933\"> Avaliable url: </h3> </a> <br> "
    @urlNumber = 0
    @readFileNameArray.each do |name|
      if File.file?(name)
        print "Reading: #{name}"
        readMyFile name
        writeToMyFile name
      else
        puts  "File #{name} does not exist"
      end
    end
  end

private

  def getStyle
    return File.read('css/style.css') if File.file?('css/style.css')
    raise "CSS file not found!"
  end

  def split_name fileName
    newName = 'CodeFile'
    if fileName.split('\\').size > fileName.split('/').size
      newName = @readFileName1.split('\\')
    else
     newName = @readFileName1.split('/')
   end
   return newName
  end

  def disply_percente line, numLines
    precenteDone = (line*100/numLines).to_i
    print (" " + precenteDone.to_s + "%") if (precenteDone % 25 == 0 and precenteDone > 0)
    print " ." if line%10 == 0
    return (line += 1)
  end

  def readMyFile fileName
    numLines = File.foreach(fileName).count
    lineCounter = 0
    precenteDone = 0
    counter = 0
    headerc = false
    firstFunc = true
    file = File.new(fileName, "r:Iso-8859-1")
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
  end

  def writeToMyFile fileName
    newName = split_name fileName
    codeFileNewname = "Code_From_#{newName[-1].split('.')[-2]}.html"
    style = getStyle
    htmlHeader = "<!DOCTYPE html>\n <html>\n    <head>\n      <style>\n#{style}\n      </style>\n    </head>"
    htmlBody = "<body> <div id=\"content\"> <div id=\"sidebar\"> <h2 style=\"color:white\"> Contents </h2>" + @fileHeader + "</div> <div id=\"main\"> <div class=\"container\" id=\"title\"> <h1 style=\"color: #ff9933\"> Code functions </h1> <font color=\"#ff9933\"> (Version: " + Time.now.to_s  + ") </font> </div> <div class=\"container\" id=\"main1\"> <br> "  + @webUrl + @fileCode + " </div> </div> </div> <footer> <p>Code By: AA @ <a href=\"https://github.com/onereallylongname\"> github</a></p></footer> </body> </html>"
    File.write(codeFileNewname, htmlHeader + htmlBody)
    puts " Done!"
  end

end

FileCToHtml.new(ARGV)
