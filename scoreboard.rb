#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

require 'json'

require 'sinatra/base'
require 'pusher'

require 'redis'
require 'redis-objects'

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
    @match = Match.new(params[:one], params[:two])
    @match.reset_scores
    @match.reset_games
    push_scores
    JSON match.scores
  end

  put '/reset_scores' do
    match.reset_scores
    match.reset_games
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

  private

  def match
    @match ||= Match.new
  end
end
