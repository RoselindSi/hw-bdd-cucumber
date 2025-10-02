class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
  
    raw_ratings = params[:ratings]
    raw_ratings = raw_ratings.keys if raw_ratings.is_a?(ActionController::Parameters) || raw_ratings.is_a?(Hash)
    selected_ratings = Array(raw_ratings).reject(&:blank?) if raw_ratings.present?
  
    @ratings_to_show = selected_ratings.presence || session[:ratings] || @all_ratings
  
    sort_param = (params[:sort] || params[:sort_by]).presence_in(%w[title release_date])
    @sort = sort_param || session[:sort] 
  
    needs_redirect = false
    query = {}
  
    unless params[:ratings].present?
      needs_redirect = true
      query[:ratings] = Hash[@ratings_to_show.map { |r| [r, 1] }]
    else
      query[:ratings] = params[:ratings]
    end
  
    unless params[:sort].present?
      needs_redirect = true if @sort.present?
      query[:sort] = @sort if @sort.present?
    else
      query[:sort] = params[:sort]
    end
  
    if needs_redirect
      flash.keep
      return redirect_to movies_path(query)
    end
  
    session[:ratings] = @ratings_to_show
    session[:sort]     = @sort
  
    @movies = Movie.where(rating: @ratings_to_show)
    @movies = @movies.order(@sort) if @sort.present?
  end
  
  

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end