require "octokit"
require "addressable/template"

if ARGV.size == 1
  output_path = ARGV.first
else
  output_path = "."
end

def get_repos_page(client, page, per_page = 100)
  puts "Reading page #{page}"
  client.search_repos "language:javascript",
    :sort => "stars",
    :order => "desc",
    :per_page => per_page,
    :page => page
end

client = Octokit::Client.new :access_token => ENV["GITHUB_ACCESS_TOKEN"]

page = 1
results = get_repos_page(client, page)

while results.items.size > 0
  for item in results.items
    filename = item.full_name.gsub("/", "-") + ".tgz"
    puts "Looking for #{filename} tarball"

    t = Addressable::Template.new(item.archive_url)
    archive_url = t.expand(:archive_format => "tarball").to_s
    puts "found archive #{archive_url}"

    response = client.agent.call :get, archive_url
    # Attempt to follow one redirect
    if response.status == 302
      archive_url = response.headers["location"]
      puts "following redirect to #{archive_url}"
      response = client.agent.call :get, archive_url
    end

    if response.data && response.data.size > 0
      puts "Writing #{filename} #{response.data.size/1024} KB"
      $stdout.flush
      File.open(File.join(output_path, filename), "w") do |file|
        file.write response.data
      end
    else
      puts "Skipping #{filename}, data not available"
    end

    # Be nice / follow the rules
    if client.rate_limit.remaining == 0
      n = client.rate_limit.resets_in
      puts "rate limit reached, waiting #{n} seconds"
      sleep n
    else
      puts "rate remaining #{client.rate_limit.remaining}"
    end
  end

  page += 1
  results = get_repos_page(client, page)
end
