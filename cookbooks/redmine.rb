%w(postgresql-server postgresql-devel).each do|pkg|
  package pkg do
  end
end

%w(httpd httpd-devel).each do|pkg|
  package pkg do
  end
end

%w(ImageMagick ImageMagick-devel).each do|pkg|
  package pkg do
  end
end

execute "install bundler" do
  user node["ruby"]["user"]
  command "/home/#{node["ruby"]["user"]}/.rbenv/bin/rbenv exec gem install bundler"
end
