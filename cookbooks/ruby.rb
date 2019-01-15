%w(gcc openssl-devel readline-devel git zlib-devel curl-devel libyaml-devel libffi-devel).each do |pkg|
  package pkg do
    action :install
  end
end

directory "#{node["ruby"]["path"]}" do
  owner node["ruby"]["user"]
  mode '0755'
  action :create
end

git "#{node["ruby"]["path"]}" do
  user 'root'
  repository "git://github.com/sstephenson/rbenv.git"
end

directory "#{node["ruby"]["path"]}/plugins" do
  owner node["ruby"]["user"]
  mode '0755'
  action :create
end

execute "Add rbenv to bash_profile" do
  user node["ruby"]["user"]
  command "echo 'export RBENV_ROOT=/usr/local/.rbenv' >> ~/.bash_profile;" \
          "echo 'export PATH=\"#{node["ruby"]["path"]}/bin:$PATH\"' >> ~/.bash_profile;" \
          "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile"
  not_if "grep 'rbenv init' ~/.bash_profile"
end

#ruby build
git "#{node["ruby"]["path"]}/plugins/ruby-build" do
  user node["ruby"]["user"]
  repository "git://github.com/sstephenson/ruby-build.git"
end

execute "ruby install" do
  user node["ruby"]["user"]
  command "source ~/.bash_profile; #{node["ruby"]["path"]}/bin/rbenv install #{node["ruby"]["version"]}"
  not_if "source ~/.bash_profile; #{node["ruby"]["path"]}/bin/rbenv versions | grep #{node["ruby"]["version"]}"
end

execute "set global ruby version #{node["ruby"]["version"]}" do
  user node["ruby"]["user"]
  command "source ~/.bash_profile; #{node["ruby"]["path"]}/bin/rbenv global #{node["ruby"]["version"]};#{node["ruby"]["path"]}/bin/rbenv rehash"
end
