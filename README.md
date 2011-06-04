Automatic Generation of Artifacts for Two Web Application Testing Models
=============

Abstract
-------

Web applications are prevalent and it is important that they be of high quality since businesses, schools, and public services rely upon them.  Unique testing models designed for web applications can be beneficial since web applications differ greatly from desktop applications.  Web applications are accessed via a browser, and a user can manipulate the web application in ways not possible with desktop applications, such as modifying the URI or using the Back button in the browser.  It can take a great deal of time to apply a given testing model to a web application, due to the size of the application as well as the many steps in applying a model.  This project seeks to decrease the time necessary to apply two particular web application testing models:  the Atomic Section Model (Jeff Offutt, Ye Wu) and the Qian, Miao, Zeng model (Zhongsheng Qian, Huaikou Miao, Hongwei Zeng).  Two tools were written using the Ruby programming language, one for each model.  The tools take as input the source code of a Ruby on Rails web application, and the URI to a web application written with any framework, respectively.  They produce as output test paths that can be traversed manually to ensure good coverage of the web application, and artifacts that can be further manipulated manually to produce test paths, respectively.  Through the use of these tools, a web application developer can better see how to test his or her application, and can see all the paths through the application that a user might take.

The project
----------

This was my Master's project at the University of Kentucky.  I provide the source code here for anyone who might get some use out of it, either by using my tools to test their web applications, or by seeing how I accomplished some task with Ruby.  See `presentation.pdf`/`presentation.pptx` for an overview of the whole project.  See `paper.docx` for a write-up of the entire project.  The project is divided into two tools, one for applying the QMZ model to a web application, the other for applying the ASM to a web app.

Usage instructions
-----------

Several libraries are necessary to run either the QMZ or the ASM scripts.  You will need to install [Treetop](http://treetop.rubyforge.org/), [Nokogiri](http://nokogiri.org/), and possibly others I am forgetting.  There is no installer as of yet to install all dependencies for you.  To run the QMZ tool, run `ruby qmz/scraper.rb` and it will provide more help.  To run the ASM tool against a single ERB file, run `ruby asm/single_file_generator.rb`.  To run the ASM tool against an entire Rails application, run `ruby asm/generator.rb`; both will provide further instructions.

Sample commands:

    ruby qmz/scraper.rb -u "http://example.com/"
    ruby asm/single_file_generator.rb app/views/test/_feedback.html.erb "http://example.com"
    ruby asm/generator.rb myRailsApp "http://example.com"

Copyright
---------

The two papers describing the web application testing models are at `asm/Modeling presentation layers of web applications for testing.pdf` and `qmz/practicalmethodfortestingwebapp.pdf`, copyright to their respective authors.  My source code I release under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0.html).

