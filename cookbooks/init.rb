# yum update
execute "update yum repo" do
  user "root"
  command "yum -y update"
end

#install git
package "git" do
  version node['git']['version']
end
