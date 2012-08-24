require 'uri'

Puppet::Type.newtype(:httpfile) do
  
  @doc = 'Download and verify files through HTTP'
  
  feature :hash, 'The ability to hash the downloaded file', :methods => [:hash]
  
  ensurable
  
  newparam :source do

    desc 'Where to download the file from'

    validate do |v| 
      resource[:source] = URI.parse(v) # raises InvalidURIError if invalid
    end

  end
  
  newparam :hash, :required_features => %w{hash} do
  
    desc 'What is the hash of the file or where from to download the hash?'
    
    validate do |v|
      begin
        resource[:hash] = URI.parse(v)
        resource[:hash_is_uri] = true
      rescue InvalidURIError => e
        unless v.length > 0
          raise ArgumentError, 'the value needs to be non-empty' 
        end
        resource[:hash] = v
        resource[:hash_is_uri] = false
      end
    end
    
  end
  
  newparam :path do
    
    desc "Where to place the downloaded file"
    
    isnamevar
    
    validate do |v|
      if value.length == 0 
        raise ArgumentError, 'only non-empty values allowed'
      end
      resource[:path] = v
    end
    
  end
  
end