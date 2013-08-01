class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort_type = params["sort"]
    @all_ratings = Hash.new()
    @checkked_buttons = Array.new
    # flash[:notice] = "Params: #{params}"
    all_ratings = Movie.select(:rating).map(&:rating).uniq.sort
    if params["commit"] == "Refresh"
      all_ratings.each {|rating| @all_ratings[rating]=false}
      @checked_buttons = params["ratings"].keys
      @checked_buttons.each  {|rating| @all_ratings[rating]=true} 
      @movies = Movie.where(:rating => @checked_buttons).all
      # flash[:notice] = "Checked_Buttons: #{params["ratings"]}"
    else
      case @sort_type 
        when 'title'   
          @movies = Movie.order('title')
        when 'release_date'  
          @movies = Movie.order('release_date')
        else 
          @movies = Movie.all
        all_ratings.each {|rating| @all_ratings[rating]=true}
      end
    end
    
    
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
