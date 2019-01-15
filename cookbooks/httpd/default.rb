remote_file "/etc/httpd/conf.d/redmine.conf" do
  owner "root"
  group "root"
end

remote_file "/etc/httpd/conf/httpd.conf" do
  owner "root"
  group "root"
end

execute "start apache" do
  command "sudo service httpd start && "\
          "sudo chkconfig httpd on && " \
          "sudo chown -R apache:apache #{node["redmine"]["path"]}"
end

