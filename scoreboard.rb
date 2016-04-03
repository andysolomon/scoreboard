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

Pusher.url = "http://2d114d0df3e7b825a420:1dc36e9309d1e22e476c@api.pusherapp.com/apps/11279"

class Scoreboard < Sinatra::Base

  get '/' do
    erb :index, locals: { scores: match.scores }
  end

  post '/new_game' do
    upload
    teams = ["Lexus", "Porsche", "Ferrari", "Tesla", "BMW", "Mercedes", "Jaguar", "Audi", "Bugatti", "Maserati", "Lamborghini"]
    newTeams = teams.dup
    newTeams.delete_at(rand(1..teams.count))
    name_one = teams[rand(1..teams.count)]
    name_two = newTeams[rand(1..newTeams.count)]
    # @match = Match.new(params[:one], params[:two])
    @match = Match.new(name_one, name_two)
    @match.reset_scores
    @match.reset_games
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
        :access_key_id => 'AKIAIEOGU4UW4CIPRJHA',
        :secret_access_key => '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')
    file_name = "public/temp.json"
    bucket = s3.buckets['scoreboardlog']
    puts bucket.objects['history'].write(:file => file_name)
  end

  private

  def match
    @match ||= Match.new
  end
end
