Hua: A Simple Static Content Generator

Hua Basics

   Hua ([7]simplified Chinese for flower) is a simple, feature-rich,
   static content generator useful for maintaining blogs and web sites
   with templates. It was initially developed by [8]Just Right UX as an
   in-house blogging tool, and has sufficiently matured for general blog
   and web site usage. Check out the Just Right UX [9]blog to see an
   example of Hua in action.

   Hua is written in the [10]Ruby scripting language and was inspired in
   part by the venerable Perl-based blogging tool [11]Blosxom and similar
   static content generators. Simplicity is one of its core principles:
   the database containing blog entries, the blog content, includes, and
   template files are maintained in plain text. Comments are provided
   through a through a third-party engine like [12]Disqus or
   [13]IntenseDebate. In keeping with the principle of simiplicity, Hua
   requires no external Ruby libraries, is small in size, and runs on any
   modern OS. Hua is open source software ([14]MIT License) and its
   codebase is [15]hosted on GitHub.

Requirements

   Hua requirements are minimal: It will run an any modern OS with a Ruby
   installation. Hua has been developed and tested on the following
   platforms:
     * macOS High Sierra ruby 2.3.3p222 (2016-11-21 revision 56859)
       [universal.x86_64-darwin17]
     * Windows 10 ruby 2.4.4p296 (2018-03-28 revision 63013) [x64-mingw32]
     * Cygwin on Windows 10 ruby 2.3.6p384 (2017-12-14 revision 9808)
       [x86_64-cygwin]
     * Linux (CentOS) ruby 2.0.0p648 (2015-12-16) [x86_64-linux]

Downloading

   Hua is hosted on GitHub, where you can [16]clone or download the Git
   repository.

Using Hua

   Hua is run from the command line by specifying the Hua script and
   config file. For example: user@host: ~/Documents/hua ./hua.rb hua.cfg.
   An example site (config file, entries file, and content) is included in
   the distribution so you can try it out immediately.

Config File

   The Hua [17]config file specifies the locations of the support files
   and variables used by Hua (article meta info, output/content/include
   directories, URLs).

Entries File

   The [18]entries file is a delimited plain-text database of articles. It
   can be edited with a text editor or a spreadsheet application (provided
   the plain-text format is preserved). Each line consists of the
   following fields:
    1. ID: A numeric field. Articles are sorted and presented in
       descending order using this field.
    2. Title: Appears at the top of the article and is linked to the
       article's permalink.
    3. File: The filename of the article's template, stored in the
       content_dir.
    4. Tags: Article-specific tags ("|" delimited). In addition to index
       and permalink pages, articles appear in the appropriate tag pages.
    5. Date: The date presented with the article. Note: This doesn't
       control the position of the article on the index and tag pages, ID
       does that.
    6. Author: Individual or organization name associated with the
       article.
    7. Contact: Individual or organization email associated with the
       article.

Errors

   Hua is normally silent, so if everything goes well nothing will be
   output on the command line. Errors will be output in the following
   situations:
     * No config file is specified. Hua will stop.
     * The config file can't be found. Hua will stop.
     * A config variable doesn't exist in the config file. Hua will stop.
     * The header/footer include doesn't exist. Hua will stop.
     * The entries file doesn't exist. Hua will stop.
     * The output directory doesn't exist. Hua will stop.
     * The read more/comments include doesn't exist. Hua will continue.
     * An article content file doesn't exist. Hua will continue to the
       next article.
     * The ID column for an entry in the entries file is empty. Hua will
       continue to the next article.
     * The file column for an entry in the entries file is empty. Hua will
       continue to the next article.

Additional Usage Information

     * If you want Hua to regenerate an existing article, delete the
       appropriate article file in the output_dir and run Hua again.
     * Pass -o or --orphans as the second argument to list files in the
       output_dir that are not referenced in the entries_file. If there
       are no orphans, nothing is output. Content is not processed in this
       mode.

Future & Contributing

   Possible future enhancements include:
     * Markdown support

   You can contribute to Hua's development by [19]suggesting improvements,
   [20]reporting issues, or [21]writing code.

References

   7. https://translate.google.com/?client=safari&rls=en&bav=on.2,or.&biw=1240&bih=907&um=1&ie=UTF-8&hl=en&client=tw-ob#auto/zh-CN/flower
   8. http://justrightux.com/
   9. http://justrightux.com/blog
  10. https://www.ruby-lang.org/en/
  11. http://blosxom.sourceforge.net/
  12. https://disqus.com/
  13. https://intensedebate.com/
  14. https://raw.githubusercontent.com/JustRightJeff/hua/master/LICENSE.txt
  15. https://github.com/JustRightJeff/hua
  16. https://github.com/JustRightJeff/hua
  17. https://raw.githubusercontent.com/JustRightJeff/hua/master/hua.cfg
  18. https://github.com/JustRightJeff/hua/blob/master/example/content/entries.csv
  19. mailto:jeff@justrightux.com
  20. https://github.com/JustRightJeff/hua/issues
  21. https://github.com/JustRightJeff/hua