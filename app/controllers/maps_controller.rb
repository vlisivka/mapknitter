require 'open3'

class MapsController < ApplicationController
  protect_from_forgery :except => [:export]
  before_filter :require_login, :only => [:create, :new, :edit, :update, :destroy]

  layout 'knitter2'

  def index
    @maps = Map.page(params[:page]).per_page(24).where(:archived => false,:password => '').order('updated_at DESC')
    render :layout => 'application2'
  end

  def new
    @map = current_user.maps.create(:author => current_user.login)
  end

  def create # should try to catch lat=0 lon=0 maps and error
    @map = current_user.maps.create(params[:map])
    if @map.save
      redirect_to "/map/#{@map.id}"
    else
      render "new"
    end
  end

  def view # legacy route, redirect later
    @map = Map.find_by_name params[:id]
    # legacy; later, just redirect this
    # redirect_to "/map/#{@map.id}", :status => :moved_permanently
    render :template => 'map/view', :layout => 'application'
  end

  def show
    if params[:legacy] # remove; legacy
      @map = Map.find_by_name params[:id]
    else
      @map = Map.find params[:id]
    end
    @map.zoom = 12
    # remove once legacy is deprecated
    render :template => 'map/show', :layout => 'knitter' if params[:legacy]
  end

  def edit
    @map = Map.find params[:id]
    @map.zoom = 12
  end

  def update
    @map = Map.find params[:id]

    # save lat, lon, location, description 
    @map.description = params[:map][:description]
    @map.location = params[:map][:location]
    @map.lat = params[:map][:lat]
    @map.lon = params[:map][:lon]

    # save new tags
    if params[:tags]
      params[:tags].gsub(' ', ',').split(',').each do |tagname|
        @map.add_tag(tagname.strip, current_user)
      end
    end

    @map.save

    redirect_to :action => "edit"
  end

  def destroy
  end

  def export
    map = Map.find params[:id]
    render :text => map.run_export(current_user)
  end

  # list by region
  def region
    area = params[:id] || "this area"
    @title = "Maps in #{area}"
    ids = Map.bbox(params[:minlat],params[:minlon],params[:maxlat],params[:maxlon]).collect(&:id)
    @maps = Map.where('id IN (?)',ids).paginate(:page => params[:page], :per_page => 24)
    render "maps/index", :layout => "application2"
  end

  # list by license
  def license
    @title = "Maps licensed '#{params[:id]}'"
    @maps = Map.where(password: '',license: params[:id]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 24)
    render "maps/index", :layout => "application2"
  end

end
