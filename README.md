# Arduino_to_HTML_docs
It's a small ruby script that helped me to keep track of my esp8266 code (while using the Ardiuno IDE).
However it works with c, cpp, and js.

# How it work
This script uses patterns in your comments to decide what to write to the html page. Some are custom made for this purpose, others are from the language.
Use the patterns to define what goes to the page and how it's represented.

# Usage
As you comment your code you can use some patterns to specify the script how to represent them.
Only code on a title or inside a block is used in the html file
Blocks: everything inside the block tab appears, code or comment. The comments have a light font color.
the custom tags dscr, args, rtrn appear highlighted in the page.   

### Output
You can check the results from the example code in the out folder.
The code output name is: Code_From_<file name>.html , where <file name> is your file name.

### Patterns
|Patterns   | name          | HTML
| --------- | ------------- | ------
| //1>      | title 1       |  h1
| //2>      | title 2       |  h2
| //3>      | title 3       |  h3
| //B>      | Start Block   | ----
| //B<      | End Block     | ----
| dscr:     | Description   | dscr
| args:     | Arguments     | args
| rtrn:     | Return value  | rtrn
| /*        | Start comments| comment color
| \*/        | End comments  | comment color
| \#include  | include       | ----
*Only for esp8266*
| server.on | Custom path   | If used appears as a separate Title

### Arguments
From the console:
-v/-version   Version
-h/-help      Help
-i            Set input path
-o            Set output path
-e/-esp       Before a file that uses the Arduino esp8266 syntax

To generate the example html files use
```
ruby code_esp8266_c_cpp_to_html.rb -i example -o out -e example.ino example2.ino
```
