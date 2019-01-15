# yum update
execute "update yum repo" do
  command "sudo yum -y update"
end

#install git
package "git" do
  version node['git']['version']
end
