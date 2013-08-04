class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def sorted_results(sort_cond, sort_type)   
    # Get the records from the database, sort as needed
    @movies = Movie.where(:rating => sort_cond).all
    if sort_type != nil
      if sort_type == 'title'
        @movies.sort! {|t1, t2| t1.title <=> t2.title }
      elsif sort_type == 'release_date'
        @movies.sort! {|r1, r2| r1.release_date <=> r2.release_date}
      end
    end
  end

  def redirect 
    redirect_str = ''
    if session[:sort] != nil    
      redirect_str = "?sort="+session[:sort] 
    else
      redirect_str = "?"
    end
    session[:ratings].each {|rating, val| redirect_str = redirect_str+'&ratings['+rating+']='+'1' unless val == false }
    redirect_str[1] = "=" unless session[:sort] != nil

    flash.keep # Make sure we keep Flash infos if any intact    
    redirect_to movies_path+redirect_str, status: 302
  end

  def set_ratings
    ratings = Movie.select(:rating).map(&:rating).uniq.sort
    ratings.each {|rating| @ratings[rating] = true}
    session[:ratings] =@ratings  
  end

  def adjust_ratings
    if params["ratings"] != nil
      # Get the new ratings
      param_ratings = params["ratings"].keys      
      if param_ratings.length > 0
        ratings = session[:ratings].keys
        ratings.each {|rating| @ratings[rating] = false}        
        param_ratings.each {|rating| @ratings[rating] = true}
        session[:ratings] = @ratings            
      end
    end
  end

  
   new_button_values  = Proc.new{|rating, val| buttons << rating unless val == false}


  def index
    @sort_type = ''       
    @ratings = Hash.new()      
    checkked_buttons = []
=begin
    flash[:notice] = "session_data: sort_type: #{session[:sort]}, 
    ratings: #{session[:ratings]}, cur_params: #{params}}"
=end

     
    if (params["sort"] == nil && params["commit"] == nil && 
       session[:sort] ==nil && session[:ratings] == nil)
      # This should happen first time user visits site
       set_ratings
       session[:ratings].each {|rating, val| checkked_buttons << rating unless val == false}
       #session[:ratings].each new_button_values.call(checkked_buttons)       
    elsif params["commit"] == "ratings_submit"
      # user pressed to do 'rating submit', adjust ratings if needed      
      adjust_ratings
      # Session had sort, Make RESTful URI redirect, if we need to sort
      return redirect unless session[:sort] == nil
      session[:ratings].each {|rating, val| checkked_buttons << rating unless val == false}
      #session[:ratings].each new_button_values.call(checkked_buttons)
      @ratings = session[:ratings]
    elsif params["sort"] != nil && params["ratings"] == nil
      # user is sorting, non redirect case
      @sort_type = params["sort"]
      session[:sort] = @sort_type # remember it
      session[:ratings].each {|rating, val| checkked_buttons << rating unless val == false}
      # session[:ratings].each  new_button_values.call(checkked_buttons)      
    elsif params["commit"] == nil && params["ratings"] != nil
      # this is the case, we got here because of our own redirection
      @sort_type = params["sort"]
      checkked_buttons << params["ratings"].keys
      # session[:sort] = @sort_type     
    elsif params["sort"] == nil &&  params["ratings"] == nil
      # Make RESTful URI redirect
      return redirect
    else
      flash[:notice] = "Unexpected Parameters"
      return
    end
    @ratings =session[:ratings]
    # @sort_type = session[:sort]
    @ratings.each {|rating, val| checkked_buttons << rating unless val == false}   
    sorted_results(checkked_buttons, @sort_type)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created." 
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."    
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end