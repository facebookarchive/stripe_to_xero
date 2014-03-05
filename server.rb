require 'sinatra'

get "/" do
  "yo!"
end

get "/run_stripe" do
  `./auto_import.sh`
end
