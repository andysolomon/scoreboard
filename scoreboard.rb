#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

require 'json'

require 'sinatra/base'
require 'pusher'

require 'redis'
require 'redis-objects'
require 'aws-sdk'

require 'connection_pool'
redis_url = ENV['REDIS_URL']
Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(url: redis_url) }

require './lib/match'
require './lib/player'
require './lib/team'

Pusher.url = "http://2d114d0df3e7b825a420:1dc36e9309d1e22e476c@api.pusherapp.com/apps/11279"

require 'thread'
require 'net/http'
require 'httparty'
Thread.abort_on_exception = true
Thread.new do |t|
  uri = URI('https://api.particle.io/v1/devices/events?access_token=d8ffe9eab7bf2047aecd74effb5499c72013e149')
  buffer = ''
  Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
    request = Net::HTTP::Get.new uri
    puts "making request"
    http.request(request) do |response|
      puts "reading response, begining"
      response.read_body do |chunk|
        puts "received chunk: #{chunk}"
        buffer += chunk
        puts "buffer: #{buffer}"
        if buffer.include?("\n") && buffer.include?("BUTTONPRESS")
          puts "found button press"
          buffer = ''
          HTTParty.put("http://localhost:5000/blue_scores")
        end
      end
    end
  end
end

class Scoreboard < Sinatra::Base

  get '/' do
    erb :index, locals: { scores: match.scores }
  end

  post '/new_game' do
    #upload
    teams = ["Lexus", "Porsche", "Ferrari", "Tesla", "BMW", "Mercedes",
             "Jaguar", "Audi", "Bugatti", "Maserati", "Lamborghini",
             "Subaru", "Chevrolet", "Bentley", "Fiat", "Nissan",
             "Pontiac", "Volkswagen", "Acura", "Polaris", "Aston Martin",
             "Infiniti", "Pagani", "Konigsegg", "Apple Car", "Batmobile", "Alfa Romero"]
    r1 = rand(1..teams.count)
    newTeams = teams.dup
    newTeams.delete_at(r1)
    name_one = teams[r1]
    name_two = newTeams[rand(1..newTeams.count)]
    @match = Match.new(name_one, name_two)
    @match.reset_scores
    @match.reset_games
    @teams = Teams.new
    @teams.teams.clear
    push_scores
    redirect '/'
  end

  put '/reset_scores' do
    match.reset_scores
    push_scores
  end

  put '/red_scores' do
    match.add_point(:red)
    push_scores
  end

  put '/blue_scores' do
    match.add_point(:blue)
    push_scores
  end


  put '/red_undo' do
    match.undo_point(:red)
    push_scores
  end

  put '/blue_undo' do
    match.undo_point(:blue)
    push_scores
  end

  get '/scores' do
    JSON match.scores
  end

  get '/menu' do
    erb :menu
  end

  post '/add_player' do
    match.reset_scores
    match.reset_games
    player = params[:add]
    player = player.rstrip
    player = player.lstrip
    @teams = Teams.new(player)
    if @teams.teams.count > 1
      Match.new(@teams.teams[0], @teams.teams[1])
    end
    if @teams.teams.count == 1
      Match.new(@teams.teams[0])
    end
    push_scores
    redirect '/'
  end

  get '/add' do
    erb :add
  end

  def push_scores
    Pusher['scores'].trigger('update_scores', match.scores.to_json)
  end

  def upload
    data_from_json = JSON[File.read("public/temp.json")]
    data_from_json = [data_from_json] if data_from_json.class != Array
    File.open("public/temp.json","w") do |f|
      f.write(JSON.pretty_generate(data_from_json << match.scores))
    end
    s3 = AWS::S3.new(
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_KEY'])
    file_name = "public/temp.json"
    bucket = s3.buckets[ENV['AWS_BUCKET']]
    puts bucket.objects['history'].write(:file => file_name)
  end

  private

  def match
    @match ||= Match.new
  end
end
