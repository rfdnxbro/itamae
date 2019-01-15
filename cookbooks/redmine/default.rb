execute "Development Tools install" do
  command "sudo yum groupinstall -y 'Development Tools'"
end

%w(httpd httpd-devel).each do|pkg|
  package pkg do
  end
end

#%w(ImageMagick ImageMagick-devel).each do|pkg|
#  package pkg do
#    options "--enablerepo=remi,epel,base"
#  end
#end

execute "install bundler" do
  user node["ruby"]["user"]
  command "source ~/.bash_profile; #{node["ruby"]["path"]}/bin/rbenv exec gem install bundler -v #{node["bundler"]["version"]}"
end

directory node["redmine"]["path"] do
  owner 'root'
  mode '0777'
  action :create
end

execute "install redmine" do
  command "svn co https://svn.redmine.org/redmine/branches/3.4-stable --trust-server-cert --non-interactive #{node["redmine"]["path"]}"
  not_if "ls #{node["redmine"]["path"]}/config"
end

remote_file "#{node["redmine"]["path"]}/config/database.yml" do
end

remote_file "#{node["redmine"]["path"]}/config/configuration.yml" do
end

directory "#{node["redmine"]["path"]}/vendor" do
  owner 'root'
  mode '0777'
  action :create
end

execute "bundle install" do
  command "source ~/.bash_profile; #{node["ruby"]["path"]}/shims/bundle install --without development test rmagick --path vendor/bundle && " \
          "#{node["ruby"]["path"]}/shims/bundle exec rake generate_secret_token && " \
          "RAILS_ENV=production #{node["ruby"]["path"]}/shims/bundle exec rake db:migrate"
  cwd node["redmine"]["path"]
end

execute "load default data and passenger install" do
  user node["ruby"]["user"]
  command "source ~/.bash_profile; RAILS_ENV=production REDMINE_LANG=ja #{node["ruby"]["path"]}/shims/bundle exec rake redmine:load_default_data &&" \
          "#{node["ruby"]["path"]}/bin/rbenv exec gem install passenger -v 5.1.12 && "\
          "#{node["ruby"]["path"]}/versions/#{node["ruby"]["version"]}/bin/passenger-install-apache2-module --auto --languages ruby"
  cwd node["redmine"]["path"]
  not_if "ls #{node["ruby"]["path"]}/versions/#{node["ruby"]["version"]}/bin/passenger-install-apache2-module"
end

execute "change owner" do
  command "sudo chown -R root:root #{node["ruby"]["path"]}"
end
