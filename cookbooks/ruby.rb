%w(gcc openssl-devel readline-devel git).each do |pkg|
  package pkg do
    action :install
  end
end

git "/home/#{node["ruby"]["user"]}/.rbenv" do
  user node["ruby"]["user"]
  repository "git://github.com/sstephenson/rbenv.git"
end

execute "Add rbenv to bash_profile" do
  user node["ruby"]["user"]
  command "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bash_profile;" \
    "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile"
  not_if "grep 'rbenv init' ~/.bash_profile"
end

directory "/home/#{node["ruby"]["user"]}/.rbenv/plugins" do
  owner node["ruby"]["user"]
  mode '0755'
  action :create
end

#ruby build
git "/home/#{node["ruby"]["user"]}/.rbenv/plugins/ruby-build" do
  user node["ruby"]["user"]
  repository "git://github.com/sstephenson/ruby-build.git"
end

execute "ruby install" do
  user node["ruby"]["user"]
  command "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv install #{node["ruby"]["version"]}"
  not_if "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv versions | grep #{node["ruby"]["version"]}"
end

execute "set global ruby version #{node["ruby"]["version"]}" do
  user node["ruby"]["user"]
  command "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv global #{node["ruby"]["version"]}"
end
