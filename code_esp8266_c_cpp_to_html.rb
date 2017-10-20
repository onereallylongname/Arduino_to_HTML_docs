# encoding: Iso-8859-1
Version = "2.0" # read multiple files
Help = "Reads files and looks for my headrs and de \"server.on\" command to write a html file.
        -v/-version Version
        -h/-help Help
        Files will appear in the order of the ARGV
        Note: This code was created to work with arduino esp8266 code!"
class FileCToHtml
  def initialize
    if ARGV.empty?; puts "No valid args!"; return; end
    if ARGV[0].eql? "-v" or ARGV[0].eql? "-version"; puts Version; return; end
    if ARGV[0].eql? "-h" or ARGV[0].eql? "-help"; puts Help; return; end
    @readFileNameArray = []
    ARGV.each { |names| @readFileNameArray.push(names.to_s) }
    @readFileName1 = @readFileNameArray[0]
    @fileCode = ""
    @knownFunctions = []
    @fileHeader = "<a href=\"#aurl\"> Avaliable url </a> <br>"
    @webUrl = "<a name=\"aurl\" <h3 style=\"color: #ff9933\"> Avaliable url: </h3> </a> <br> "
    @urlNumber = 0
    @readFileNameArray.each do |name|
    @readFileName = name
      if file_exists? name
        print "Reading: #{name}"
        readMyFile
        writeToMyFile
      else
        puts  "File #{name} does not exist"
      end
    end
  end

private

  def readMyFile
    lineCounter = 0
    counter = 0
    headerc = false
    firstFunc = true
    file = File.new(@readFileName, "r:Iso-8859-1")
    while (line = file.gets)
      print " ." if lineCounter%10 == 0
      lineCounter += 1
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

  def writeToMyFile
    fileOldName = @readFileName1.split('/')
    fileOldName = @readFileName1.split('\\') if @readFileName.split('\\').size > @readFileName.split('/').size
    fileOldName = fileOldName[-1].split('.')[-2]
    codeFileNewname1 = "CodeMenuFrom_#{fileOldName}.html"
    htmlHeader = "<!DOCTYPE html>
                  <html>
                  <head>
                  <style>  #content {
                    height: 95%
                    width: 100%;
                  }
                  #sidebar {
                      background-color: #ff9933;
                      position: fixed;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 235px;
                      width: 235px;
                      padding-top: 8px;
                      padding-left: 25px;
                      overflow-y: scroll;
                      height: 92%
                  }
                  #main {
                      margin-left: 350px;

                  }
                  #title {
                      position: relative;
                      opacity: 1;
                      top: 0;
                      padding-left: 50px;
                      padding-right: 50%;

                  }
                  #main1 {
                      position: relative;
                      margin-left: 20px;
                  }
                  footer {
                      background: #ff9933;
                      position:fixed;
                      left: 0;
                      padding-left: 0;
                      bottom:0px;
                      height: 7.1%;
                      width:260px;
                      text-align: center;
                  }
                  ::-webkit-scrollbar {
                      width: 5px;
                  }
                  a:link {
                      text-decoration: none;
                  }
                  a:link, a:visited {
                      color: white;
                      text-decoration: none;
                      cursor: auto;
                  }
                  a:link:active, a:visited:active {
                      color: black;
                      text-decoration: none;
                  }
                  </style>
                  </head>"
    fileNewCode = htmlHeader + "<body> <div id=\"content\"> <div id=\"sidebar\"> <h2 style=\"color:white\"> Contents </h2>" + @fileHeader + "</div> <div id=\"main\"> <div class=\"container\" id=\"title\"> <h1 style=\"color: #ff9933\"> Code functions </h1> <font color=\"#ff9933\"> (Version: " + Time.now.to_s  + ") </font> </div> <div class=\"container\" id=\"main1\"> <br> "  + @webUrl + @fileCode + " </div> </div> </div> <footer> <p>Code By: AA @ <a href=\"https://github.com/onereallylongname\"> github</a></p></footer> </body> </html>"
    File.write(codeFileNewname1, fileNewCode)
    puts " Done!"
  end
  def file_exists?(fileName)
    File.file?(fileName)
  end

end

FileCToHtml.new
