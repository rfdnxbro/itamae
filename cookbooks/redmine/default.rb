include_recipe '../postgres/default.rb'

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
  command "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv exec gem install bundler -v #{node["bundler"]["version"]}"
end

# 手動実行必要...
execute "install redmine" do
  command "sudo mkdir -m 777 /var/lib/redmine && "\
          "svn co https://svn.redmine.org/redmine/branches/3.4-stable /var/lib/redmine"
  not_if "ls /var/lib/redmine/"
end

remote_file "/var/lib/redmine/config/database.yml" do
end

remote_file "/var/lib/redmine/config/configuration.yml" do
end

execute "bundle install" do
  command "/home/#{node["ruby"]["user"]}/.rbenv/shims/bundle install --without development test rmagick --path vendor/bundle && " \
          "/home/#{node["ruby"]["user"]}/.rbenv/shims/bundle exec rake generate_secret_token && " \
          "RAILS_ENV=production /home/#{node["ruby"]["user"]}/.rbenv/shims/bundle exec rake db:migrate"
  cwd "/var/lib/redmine/"
end

# once
#execute "bundle install" do
#  command "RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data"
#  cwd "/var/lib/redmine/"
#end

execute "passenger install" do
  user node["ruby"]["user"]
  command "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv exec gem install passenger -v 5.1.12 && "\
          "/home/#{node["ruby"]["user"]}/.rbenv/versions/#{node["ruby"]["version"]}/bin/passenger-install-apache2-module --auto --languages ruby"
  cwd "/var/lib/redmine/"
  not_if "ls /home/#{node["ruby"]["user"]}/.rbenv/versions/#{node["ruby"]["version"]}/bin/passenger-install-apache2-module"
end

include_recipe '../httpd/default.rb'
