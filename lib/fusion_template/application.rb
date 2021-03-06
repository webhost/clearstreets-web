require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"

module FusionTemplate
  class Application < Sinatra::Base
    enable :logging, :sessions
    enable :dump_errors, :show_exceptions if development?

    configure :development do
      register Sinatra::Reloader
    end
    
    register Sinatra::Initializers
    register Sinatra::R18n

    before do
      session[:locale] = params[:locale] if params[:locale]
    end

    use Rack::Logger
    use Rack::Session::Cookie

    helpers FusionTemplate::HtmlHelpers

    Past_storms = [
      {:carto_db_url => 'http://clearstreets.cartodb.com/tables/9446/public/map', :title => 'Dec 25, 2013', :backup_folder => '12-27-2013', :snowfall => '1.2 inches'},
      {:carto_db_url => 'http://clearstreets.cartodb.com/tables/9215/public/map', :title => 'Dec 22, 2013', :backup_folder => '12-25-2013', :snowfall => '2 inches'},
      {:carto_db_url => 'http://clearstreets.cartodb.com/tables/8961/public/map', :title => 'Dec 17, 2013', :backup_folder => '12-19-2013', :snowfall => '1 inch'},
      {:carto_db_url => 'http://clearstreets.cartodb.com/tables/7862/public/map', :title => 'Dec 16, 2013', :backup_folder => '12-17-2013', :snowfall => '2 inches'},
      {:carto_db_url => 'http://clearstreets.cartodb.com/tables/7348/public/map', :title => 'Dec 13-14, 2013', :backup_folder => '12-16-2013', :snowfall => '4.2 inches'},
      {:fusion_table_id => '129O2iei3jOpvTT_yG2xjHjY2hvunTb4IzTHBj_A', :title => 'Dec 10-11, 2013', :type => '', :backup_folder => '12-11-2013', :snowfall => '0.9 inches'},
      {:fusion_table_id => '1dOMXfBMwQeYA8hQ2aWgK7ey6rRX4pebXmVB2pIM', :title => 'Dec 8, 2013', :type => '', :backup_folder => '12-10-2013', :snowfall => '3.1 inches'},
      {:fusion_table_id => '1RIRVDtmgZxBet1Hd9kJi6GLdvl9dC45SrtzsAko', :title => 'Mar 5, 2013', :type => '', :backup_folder => '03-06-2013'},
      {:fusion_table_id => '1yYkZlNtZHFfAZ4vdOi2jTvIDV4hdkd2XmoicJ9U', :title => 'Feb 26-27, 2013', :type => '', :backup_folder => '02-27-2013'},
      {:fusion_table_id => '1o5iP9qK0YnCcuqIQ8G3KkgA8qGQEaI8HrxlXKbs', :title => 'Feb 22, 2013', :type => '', :backup_folder => '02-22-2013'},
      {:fusion_table_id => '1fBpR7sN8avSbL1Zc0Ye8rs7Qkww-4raKLm0WrwM', :title => 'Feb 7, 2013', :type => '', :backup_folder => ''},
      {:fusion_table_id => '1ejPv2ivummsG1Qgn6tW1molfZul-nUHdqbdLduc', :title => 'Feb 4, 2013', :type => '', :backup_folder => '02-05-2013'},
      {:fusion_table_id => '1hYWSY3i91n8lUnCI9i2CfK1TVp2UFgx9IVjLmbo', :title => 'Feb 2, 2013', :type => '', :backup_folder => '02-03-2013'},
      {:fusion_table_id => '1NKzNt2E0ScHUs9OIM22UAmh1pQZl7geWqH1fSyg', :title => 'Jan 25-28, 2013', :type => '', :backup_folder => '01-31-2013'},
      {:fusion_table_id => '12vrI6yT7pIKFqRLPDs2BiRNdH3Y0DXzyNEISSeg', :title => 'Dec 20, 2012', :type => '', :backup_folder => '12-20-2012'},
      {:fusion_table_id => '1Joj30eltDiXAhbhizuurstPUfqYeSISEmlOANHE', :title => 'Feb 10, 2012', :type => 'legacy', :backup_folder => ''},
      {:fusion_table_id => '18LV9PXFVzgP_eZhBRcbsCWRW9sHTMLPaxx3lDa8', :title => 'Jan 21, 2012 (part 2)', :type => 'legacy', :backup_folder => ''},
      {:fusion_table_id => '1hq3bK1dUqyE6LCQ488tZF3syQQc5jYsluMS5Fy0', :title => 'Jan 21, 2012 (part 1)', :type => 'legacy', :backup_folder => ''}
    ]

    # redirects for old site
    get "/2012*" do
      redirect "/?1"
    end

    get "/about.html" do
      redirect "/about"
    end

    get "/past-storms.html" do
      redirect "/?2"
    end

    # utility for flushing cache
    get "/flush_cache" do
      require 'dalli'
      dc = Dalli::Client.new
      dc.flush
      redirect "/"
    end
    
    # primary routes
    get "/" do
      cache_control :public, max_age: 1800  # 30 min
      @current_menu = "home"
      haml :index
    end

    get "/about" do
      cache_control :public, max_age: 1800  # 30 min
      @current_menu = "about"
      haml :about
    end
    
    # catchall for static pages
    get "/:page/?" do
      begin 
        @current_menu = params[:page]
        @title = params[:page].capitalize.gsub(/[_-]/, " ") + " - ClearStreets"
        @page_path = params[:page]
        haml params[:page].to_sym
      rescue Errno::ENOENT
        haml :not_found
      end
    end

    error do
      'Sorry there was a nasty error - ' + env['sinatra.error'].name
    end
  end
end
