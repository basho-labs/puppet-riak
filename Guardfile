# A sample Guardfile
# https://github.com/guard/guard

guard 'rake', :task => 'lint' do
  watch(%r{^.+\.pp$})
end

# ['spec/*/*_spec.rb']
guard 'rspec', :version => 2, :spec_paths => 'spec/functions/', :cli => '--color' do
  watch(%r{^spec\/.+_spec\.rb$})
  watch(%r{^spec\/shared_contexts\.rb$})
  watch(%r{^manifests\/(.+)\.pp$}) {
    |m| puts 'riakspec' ; 'spec/classes/riak_spec.rb' if m[1] == 'init'
  }
  watch(%r{^manifests\/(.+)\.pp$}) {
    |m| puts "#{m[1]}-spec" ; "spec/classes/#{m[1]}_spec.rb" unless m[1] == 'init'
  }
end
