class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    self.restore_session
    # flash[:notice] = "session: #{session}"
  end

  def save_session(params=nil)
    session[:sort_type] = @sort_type
    session[:subnit_type] = @submit_type
    session[:param_str] = @param_str
    session[:params] = params
    if @checkked_buttons != []
        session[:checkked_button] = @checkked_buttons         
        session[:all_ratings] = @all_ratings
    end    
    if @submit_type == "commit"
      @submit_str="?utf8="+params["utf8"]
      params["ratings"].each do |key, val|
        str = '&ratings['+key+']='+val
        @submit_str = @submit_str+str
      end
      @submit_str = @submit_str+"&commit="+params["commit"]
    end
    session[:submit_str] = @submit_str
  end

  def restore_session
    @sort_type = session[:sort_type]
    @param_str = session[:param_str]
    @submit_type = session[:subnit_type]     
    @checkked_buttons = session[:checkked_button]        
    @all_ratings = session[:all_ratings]
    @submit_str = session[:submit_str]
    params = session[:params]
  end

  def index
    @sort_type = params["sort"]
    @submit_type = ''
    @all_ratings = Hash.new()
    @checkked_buttons = Array.new
    @param_str = ''
    @submit_str = ''
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
      @submit_type = "commit"
      self.save_session(params)      
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
        self.save_session 
      else @sort_type == 'release_date'
        # @movies = Movie.order('release_date')
        @movies = Movie.where(:rating => @checkked_buttons).all
        @movies.sort! {|r1, r2| r1.release_date <=> r2.release_date}
        self.save_session      
      end
    else
      @movies = Movie.all
      all_ratings.each do |rating|
        @all_ratings[rating]=true
        @param_str = @param_str+'&'+rating+'=1'
        self.session.clear
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
