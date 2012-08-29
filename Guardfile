# A sample Guardfile
# https://github.com/guard/guard

guard 'rake', :task => 'lint' do
  watch(%r{^.+\.pp$})
end

guard 'rspec', :version => 2, :spec_paths => ["spec/classes", "spec/defines"], :cli => '--color' do
  watch(%r{^spec\/.+_spec\.rb$})
  watch(%r{^spec\/shared_contexts\.rb$})
  watch(%r{^manifests\/.+\.pp$})
end
