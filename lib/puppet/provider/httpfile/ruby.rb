require 'fileutils'
# http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html
require 'net/http'
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/digest/rdoc/Digest.html
require 'digest'

Puppet::Type.type(:httpfile).provide(:ruby) do
  
  desc "Download the file with Ruby"
  
  has_feature :hash

  @h = ""
  
  def hash
    return @h unless @h.empty?
    @h = Net::HTTP.get(resource[:hash]) if resource[:hash_is_uri]
    @h = resource[:hash]
  end

  # create the file by downloading it
  def create

    # clean badly hashing files
    FileUtils.rm resource[:path] if FileUtils.exists? resource[:path]

    try = 0
    max_tries = 3
    digest = ""
    
    while try < max_tries && hash != digest
      try++
      
      sha1 = SHA1.new
      f = open(resource[:path])
      
      begin
        # blocking...
        http.request_get(resource[:source]) do |resp|
          resp.read_body do |segment|
            f.write segment
            sha1.update segment
          end
        end
        digest = sha1.hexdigest
      ensure
        f.close()
      end
      
      return

    end
    
    raise Error, 'the file didn\'t hash correctly, retry'
    
  end

  # remove the file if it exists, no matter its hash  
  def destroy
    FileUtils.rm resource[:path] if FileUtils.exists? resource[:path]
  end
  
  # it exists if it exists and it hashes properly
  def exists?

    return false unless FileUtils.exists? resource[:path]
    
    sha1 = SHA1.new
    
    File.open resource[:path] do |file|
      buffer = ''
      while not file.eof
        file.read(512, buffer)
        sha1.update(buffer)
      end
    end
    
    sha1.hexdigest == hash
  end
  
end