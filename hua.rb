#!/usr/bin/ruby

#
# Get file and config variables
#

# Config file passed as first argument
if ARGV[0]
	if File.file?(ARGV[0]) 
		configs = IO.readlines(ARGV[0])

		#Process file and config variables
		configs.each {
			|config|
			if (config =~ /^*=/) 
				var_val = config.split '='
				
				instance_variable_set("@" + var_val[0].strip, var_val[1].strip)
			end
		}
	else
		puts "Config file error. Config file path specified as " + ARGV[0] + ". Quitting."
		exit 1
	end
else
	puts "Usage: " + File.join('.', 'hua.rb') + " [path to config file] [optional: -o|--orphans]"
	exit 1
end 

# Orphans flag passed as second argument
orphans_mode = 0
if ARGV[1]
	if (ARGV[1] == "-o" or ARGV[1] == "--orphans")
		orphans_mode = 1
	else
		puts "Usage: " + File.join('.', 'hua.rb') + " [path to config file] [optional: -o|--orphans]"
		exit 1
	end
end

# Check to make sure all file/config vars are defined or quit
config_vars = ['@entries_file', '@content_dir', '@output_dir', '@index_file', '@include_dir', '@header_file', '@footer_file', '@read_more_file', '@comments_file', '@tags_file', '@blog_root', '@web_root']

config_vars.each {
	|config|
	if not (instance_variable_defined?(config))
		puts "File/config variable error. " + config + " variable is not defined. Quitting."
		exit 1
	end
}

#
# process_tags
#
# 	input:	an array of tags
#	output: an html list of unique sorted tags
#

def process_tags(tag_array)
	tags_list = String.new

	# Make sure the list of tags is unique
	tag_array = tag_array.uniq
	
	# Sort the tag list
	tag_array = tag_array.sort

	tag_array.each {
		|tag|
		tag = tag.strip
		tags_list = tags_list + '<li><a href="tagged-with-' + tag + '.html"><span class="tag">' + tag + '</span></a></li>'		
	}
	
	return tags_list
end

#
# list_orphans
#
# 	input:	contents of entries_file, an array of output_dir article filenames
#	output: a list of orphans to stdout
#

def list_orphans(entries, output_articles)
	entries_fns = Array.new
	
	# Get the entries_file article filenames
	entries.drop(1).each {
		|entry|
		
		# Skip blank lines
		if (entry =~ /^$/)
			next
		end
		
		attributes = entry.split ','
		entries_fn = attributes[2].strip    # File name of the article
		entries_fns.push(File.join(@output_dir, entries_fn))
	}
	
	# Check for the existence of the output article in the entries
	output_articles.each {
		|output_article|
		
		# Ignore tagged-with and the index file
		if not (entries_fns.include? output_article) and not ( output_article =~ /tagged-with-/)  and not ( output_article == @index_file)
			puts output_article	
		end
	} 
end

# Get the header content (or fail)
if File.file?(@header_file) 
	header = File.read(@header_file)
else
	puts "Header error. Header path set as " + @header_file + ". Quitting."
	exit 1
end

# Get the footer content (or fail)
if File.file?(@footer_file) 
	footer = File.read(@footer_file)
else
	puts "Footer error. Footer path set as " + @footer_file + ". Quitting."
	exit 1
end

# Open the entries file and read its contents (or fail)
if File.file?(@entries_file) 
	entries = IO.readlines(@entries_file)
	# Sort the entries by ID, descending order
	entries.sort! {|x, y| y <=> x}
else
	puts "Entries file error. Entries file path set as " + @entries_file + ". Quitting."
	exit 1
end

# Check to see if the output dir exists. Quit if it doesn't
if not Dir.exists?(@output_dir)
	puts "Output directory error. Output directory path set as " + @output_dir + ". Quitting."
	exit 1
end

# Orphans mode? Then get a list of files currently in the output directory
if (orphans_mode == 1)
	output_articles = Dir.glob(File.join(@output_dir, "*.html"))
	list_orphans(entries, output_articles)
	exit 0
end

# Remove the previous index file
if File.exists?(@index_file) 
	File.delete(@index_file)
end

# Remove the previous "tagged-with" file(s)
Dir.glob(File.join(@output_dir, "tagged-with-*")) {
	|file|
	File.delete(file)
}

#
# Loop over the entries (skip the first) and output the content
#

# Array for the master tag list
tag_list = Array.new

# Open the index file for writing and write the header
index = File.open(@index_file, 'a')

# Replace the index article title placeholder with an empty string
index.write(header.sub '~~article_title~~', '')

entries.drop(1).each {
	|entry|
	
	# Skip blank lines
	if (entry =~ /^$/)
		next
	end
	
	attributes = entry.split ','
	
	id = attributes[0]                  # Unix epoch (date +%s)
	article_title = attributes[1]       # Article title
	article_fn = attributes[2].strip    # File name of the article in the content_dir
	tags = attributes[3].split '|'      # Article-specific tags
	article_date = attributes[4]        # Article date
	author = attributes[5]              # Author name
	contact = attributes[6].strip       # Author email
	
	# Array for the article tag list
	article_tags = Array.new

	# Loop over the tags
	tags.each {
		|tag|
		article_tags.push(tag.strip)
		tag_list.push(tag.strip)
	}
		
	#
	# Create/append to the index/permalink file content
	#

	# Get content of read more link include (or error)
	if File.file?(@read_more_file) 
		read_more = File.read(@read_more_file)
	else
		puts "Read more file error. Read more file path set as " + @footer_file + ". Continuing."
		read_more = ""
	end
	
	# Get the article content in content_dir, warn and skip to next if article isn't found
	article_content_file = File.join(@content_dir, article_fn)
	
	if File.file?(article_content_file)
		article_content = File.read(article_content_file)
	else
		puts "Article content error. Article content file path set as " + article_content_file + ". Skipping."
		next
	end

	# Article-specific tags
	article_content.sub! '~~article_tags~~', process_tags(article_tags)
	
	# Article permalink, date, title, and author
	article_content.sub! '~~permalink_url~~', @blog_root + article_fn
	article_content.sub! '~~article_date~~', article_date
	article_content.sub! '~~article_title~~', article_title
	article_content.sub! '~~author~~', author
	article_content.sub! '~~master_tags~~', '<!--#include virtual="/blog/inc/tags.html" -->'
	index.write(article_content.sub! '~~contact~~', contact)
	
	# Permalink (read more link)
	index.write(read_more.sub! '~~link~~', @blog_root + article_fn)
	
	#
	# Create the permalink file if it doesn't exist in the output_dir
	#
	permalink_path = File.join(@output_dir, article_fn)
	
	if not File.file?(permalink_path)		
		permalink = File.open(permalink_path, 'w')
	
		# "Reset" header content so title can be properly substituted
		header = File.read(@header_file)
		header.sub! '~~article_title~~', ' / ' + article_title
		permalink.write(header)
		permalink.write(article_content)
	
		# Substitute values in comments include (or warn and continue if comments file isn't found
		if File.file?(@comments_file)
			comments = File.read(@comments_file)
			comments = comments.sub! '~~this.page.url~~', @web_root + @blog_root + article_fn
			comments = comments.sub! '~~this.page.identifier~~', id
		else
			puts "Comments file error. Comments file path set as " + @comments_file + ". Continuing."
			comments = ""
		end
		permalink.write(comments)
	
		permalink.write(footer)
		permalink.close
	end
	
	# 
	# Tag specific files
	#
	
	# For each article tag, add the article content to the "tagged-with" file
	article_tags.each {
		|article_tag|
		
		# Tagged with filename and path
		tagged_with_fn = "tagged-with-" + article_tag.strip + ".html"
		tagged_with_path = File.join(@output_dir, tagged_with_fn)
		
		# Is the "tagged-with" file new? If so, write the header to it first
		if not File.exist?(tagged_with_path) 
			tagged_with = File.open(tagged_with_path, 'w')
			
			# "Reset" header content so title can be properly substituted
			header = File.read(@header_file)
			header.sub! '~~article_title~~', ' / Articles tagged with &quot;' + article_tag.strip + '&quot;'
			tagged_with.write(header)
			tagged_with.close
		end
				
		# Open the file for writing
		tagged_with = File.open(tagged_with_path, 'a')
		tagged_with.write(article_content)
		tagged_with.write(read_more)		
		tagged_with.close
	}
	
}

index.write(footer)
index.close

#
# Post-process "tagged-with" files
#

Dir.glob(File.join(@output_dir, "tagged-with-*")) {
	|file|
	
	# Only one master tag list should appear
	tagged_with_content = File.read(file)
	tagged_with_content.sub! '<!--#include virtual="/blog/inc/tags.html" -->', '~~temp~~'
	tagged_with_content.gsub! '<!--#include virtual="/blog/inc/tags.html" -->', ''
	tagged_with_content.sub! '~~temp~~', '<!--#include virtual="/blog/inc/tags.html" -->'
	tagged_with = File.open(file, 'w')
	tagged_with.write(tagged_with_content)
	tagged_with.close
	
	# Open the file to append and append the footer
	tagged_with = File.open(file, 'a')
	tagged_with.write(footer)
	tagged_with.close
}

#
# Post-process index file
#

# There should only be one master tag list in index
index_content = File.read(@index_file)
index_content.sub! '<!--#include virtual="/blog/inc/tags.html" -->', '~~temp~~'
index_content.gsub! '<!--#include virtual="/blog/inc/tags.html" -->', ''
index_content.sub! '~~temp~~', '<!--#include virtual="/blog/inc/tags.html" -->'
index = File.open(@index_file, 'w')
index.write(index_content)
index.close

#
# Create the tags include html
#
tags = File.open(@tags_file, 'w')
tags.write('<ul class="tags">' + process_tags(tag_list) + '</ul>')
tags.close