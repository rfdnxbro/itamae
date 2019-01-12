# https://blog.a-know.me/entry/2018/01/24/221051
node["recipes"] = node["recipes"] || []

node["recipes"].each do |recipe|
  include_recipe recipe
end
