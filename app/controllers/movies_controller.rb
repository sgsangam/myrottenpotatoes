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
    @param_str = ''
    # flash[:notice] = "Params: #{params}"
    all_ratings = Movie.select(:rating).map(&:rating).uniq.sort
    all_ratings.each {|rating| @all_ratings[rating]=false}
    if params["commit"] == "ratings_submit"
      # flash[:notice] = "Ratings: #{params["ratings"].keys}"
      @checkked_buttons = params["ratings"].keys
      # flash[:notice] = "@checkked_buttons: #{@checkked_buttons}"
      @checkked_buttons.each {|rating| @all_ratings[rating]=true}
      params["ratings"].each do |rating, val|  
        @param_str = @param_str+'&'+rating+'='+val
      end
      @movies = Movie.where(:rating => @checkked_buttons).all
    elsif @sort_type == 'title' || @sort_type == 'release_date'      
      @all_ratings.each do |rating, rval|
        params.each do |key, val|                 
          if rating == key
            @checkked_buttons << key            
            @all_ratings[rating] = true
            @param_str = @param_str+'&'+rating+'='+val
          end
        end
      end
      # flash[:notice] = "@all_ratings: #{@all_ratings}"
      # flash[:notice] = "@checked_buttons: #{@checkked_buttons}"
      if @sort_type == 'title'
        # @movies = Movie.order('title')
        @movies = Movie.where(:rating => @checkked_buttons).all
        @movies.sort! {|t1, t2| t1.title <=> t2.title }
      else @sort_type == 'release_date'
        # @movies = Movie.order('release_date')
        @movies = Movie.where(:rating => @checkked_buttons).all
        @movies.sort! {|r1, r2| r1.release_date <=> r2.release_date}     
      end
    else
      @movies = Movie.all
      all_ratings.each do |rating|
        @all_ratings[rating]=true
        @param_str = @param_str+'&'+rating+'=1'
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
