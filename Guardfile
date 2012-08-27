# A sample Guardfile
# https://github.com/guard/guard
#guard 'rake', :task => 'vagrant:provision' do
#  watch(%r{^manifests\/.+\.pp$})
#end

guard 'rspec', :version => 2, :spec_paths => ["spec/classes", "spec/defines"], :cli => '--color' do
  watch(%r{^spec\/.+_spec\.rb$})
end
