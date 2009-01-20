require 'rubygems'
require 'echoe'

# Add the project's top level directory and the lib directory to the Ruby search path
$: << File.expand_path(File.join(File.dirname(__FILE__), "lib"))
$: << File.expand_path(File.dirname(__FILE__))

require 'invoicing'

Echoe.new('invoicing', Invoicing::VERSION) do |p|
  p.summary = 'Ruby invoicing framework'
  p.description = 'Provides tools for applications which need to generate invoices for customers.'
  p.url = 'http://invoicing.rubyforge.org/'
  p.author = 'Martin Kleppmann'
  p.email = 'rubyforge@eptcomputing.com'
  p.dependencies = ['activerecord >=2.1.0']
  p.docs_host = 'ept@rubyforge.org:/var/www/gforge-projects/invoicing/docs/'
  p.test_pattern = 'test/*_test.rb' # do not include test/models/*.rb
  p.rcov_options = "-x '/Library/'"
end


desc "Generate a new website from README file"
task 'website' do
  require 'rubygems'
  require 'redcloth'
  require 'syntax/convertors/html'
  require 'erb'
  
  version  = Invoicing::VERSION
  download = 'http://rubyforge.org/projects/invoicing'
  
  def convert_syntax(syntax, source)
    return Syntax::Convertors::HTML.for_syntax(syntax).convert(source).gsub(%r!^<pre>|</pre>$!,'')
  end
  
  template = ERB.new(File.open(File.join(File.dirname(__FILE__), '/website/template.html.erb')).read)
  
  title = nil
  body = nil
  File.open(File.join(File.dirname(__FILE__), '/README')) do |fsrc|
    title = fsrc.readline.gsub(/^[^ ]* /, '')
    body_text = fsrc.read
    syntax_items = []
    body_text.gsub!(%r!<(pre|code)[^>]*?syntax=['"]([^'"]+)[^>]*>(.*?)</\1>!m){
      ident = syntax_items.length
      element, syntax, source = $1, $2, $3
      syntax_items << "<#{element} class='syntax'>#{convert_syntax(syntax, source)}</#{element}>"
      "syntax-temp-#{ident}"
    }
    body = RedCloth.new(body_text).to_html
    body.gsub!(%r!(?:<pre><code>)?syntax-temp-(\d+)(?:</code></pre>)?!){ syntax_items[$1.to_i] }
  end
  
  File.open(File.join(File.dirname(__FILE__), '/website/index.html'), 'w') do |fout|
    fout.write(template.result(binding))
  end
end


desc "Generate and publish website"
task :publish_website => :website do
  require 'net/sftp'
  upload_user = 'ept'
  upload_host = 'rubyforge.org'
  upload_dir = '/var/www/gforge-projects/invoicing'
  local_dir = File.join(File.dirname(__FILE__), 'website')
  Net::SFTP.start(upload_host, upload_user) do |sftp|
    for f in Dir.entries(local_dir)
      next if f =~ /^\./
      puts "Uploading #{f} to #{upload_user}@#{upload_host}:#{upload_dir}/#{f}"
      sftp.upload!(File.join(local_dir, f), "#{upload_dir}/#{f}")
    end
  end
end