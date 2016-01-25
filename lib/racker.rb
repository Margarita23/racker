require "erb"
require "codebreaker"
 
class Racker
  def self.call(env)
    new(env).response.finish
  end
   
  def initialize(env)
    @request = Rack::Request.new(env)
  end
   
  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/start" then start
    when "/get_guess"
      if !game.loss? && !game.win?    
        Rack::Response.new(render("game.html.erb"))
      else
        Rack::Response.new(render("end_game.html.erb"))
    end
    when "/check_guess" then check_result
    when "/hint" then hint
    when "/restart" then Rack::Response.new(render("index.html.erb"))
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
   
  def level
    @request.cookies["diff"]
  end
      
  def start
    Rack::Response.new do |response|
      @request.session.clear
      response.delete_cookie("diff")
      response.delete_cookie("att")
      response.delete_cookie("guess")
      response.delete_cookie("result")
      response.delete_cookie("hint_cookie")
      response.set_cookie("diff", @request.params["diff"])
      @request.session[:game]=Codebreaker::Game.new
      if @request.params["diff"].to_i==0
        game.start
      else
        game.start(@request.params["diff"].to_i)
      end
      response.set_cookie("att", game.instance_variable_get(:@att))
      response.redirect("/get_guess")
    end
  end
      
  def game
    @request.session[:game]
  end
      
      #----------------------> to delete
  def secret
    game.instance_variable_get(:@secret_code)
  end
      #----------------------
      
      
  def check_result
    Rack::Response.new do |response|
      
        guess_arr = @request.params["guess"].to_s.split("").map{|s| s.to_i}
        guesses = guess.to_s.concat(@request.params["guess"]).concat(" ")
        response.set_cookie("guess", guesses)
        checking = result.to_s.concat(game.submit_code(guess_arr).to_s)
        response.set_cookie("result", checking)
        response.set_cookie("result", checking)
        response.set_cookie("att", game.instance_variable_get(:@attempts))
        response.redirect("/get_guess")
     
    end
  end
      
  def guess
    @request.cookies["guess"]
  end
      
  def result
    @request.cookies["result"]
  end
      
  def hint
    Rack::Response.new do |response|
      if hint_cookie.to_s==""
        response.set_cookie("hint_cookie", game.get_hint)
      else
        response.set_cookie("hint_cookie", "no hint")
      end
      response.redirect("/get_guess")
    end
  end

  def hint_cookie
    @request.cookies["hint_cookie"]
  end
      
  #-------------for veiw`s part
      
  def attempts
    @request.cookies["att"]
  end
      
end