require "sinatra"
require "active_record"
require "rack-flash"
require "./lib/database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.new(ENV["RACK_ENV"])
  end

  get "/" do
    @test = "hello world"
    if session[:user_id]
      puts "We still have a session id #{session[:id]}"
    end
    erb :root
  end

  get "/registration" do
    erb :registration
  end

  post "/registration" do
    if params[:username] == '' && params[:password] == ''
      flash[:notice] = "Please fill in username and password"
      redirect "/registration"
    elsif params[:password] == ''
      flash[:notice] = "Please fill in password"
      redirect "/registration"
    elsif params[:username] == ''
      flash[:notice] = "Please fill in username"
      redirect "/registration"
    else
      flash[:notice] = "Thank you for registering"
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{params[:username]}', '#{params[:password]}')")
      redirect "/"
    end
  end



  post "/login" do
    current_user = @database_connection.sql("SELECT * FROM users WHERE username='#{params[:username]}' AND password='#{params[:password]}';").first
    puts "user is #{current_user}"
    session[:user_id] = current_user["id"]
    p "the session id is #{session[:user_id]}"
    flash[:not_logged_in] = true
    flash[:notice] = "Welcome, #{params[:username]}"
    redirect "/"
  end

  post "/logout" do
    session[:user_id] = nil
    p session[:user_id]
    redirect "/"
  end
end #end of class
