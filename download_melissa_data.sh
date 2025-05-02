#! /usr/bin/env ruby

#
# Download and extract Melissa Data DQS files required for the Address Service.
#
md_web_url = ENV["MD_WEB_URL"]
raise "Missing environment variable MD_WEB_URL, see README.MD for details." unless md_web_url

root_path    = File.expand_path(__dir__)
extract_path = File.expand_path(File.join(root_path, 'dqs'))
data_path    = File.expand_path(File.join(extract_path, 'data'))
dqs_path     = File.expand_path(File.join(root_path, '..', 'dqs'))

# Download the latest Melissa Data Package
if Dir.exist?(dqs_path)
  puts "Existing DQS package found in: #{dqs_path}"
else
  puts "Downloading latest DQS package into: #{dqs_path}"
  Dir.mkdir(dqs_path)
  Dir.chdir(dqs_path) do
    `wget -O dqs.zip "#{md_web_url}"`
    `unzip dqs.zip -d #{dqs_path}`
  end
end

puts "Extracting required DQS files into: #{extract_path}"
Dir.mkdir(extract_path) unless Dir.exist?(extract_path)
Dir.mkdir(data_path) unless Dir.exist?(data_path)
`cp #{dqs_path}/address/data/mdAddr.* #{data_path}`
`cp #{dqs_path}/address/linux/gcc48_64bit/libmdAddr.so #{extract_path}`
`cp #{dqs_path}/address/linux/gcc48_64bit/*.h #{extract_path}`
`chmod -R +w #{extract_path}`
