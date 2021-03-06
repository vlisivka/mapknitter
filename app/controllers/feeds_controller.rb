class FeedsController < ApplicationController

  def all
    #(Warpable.all + Map.all).sort_by(&:created_at)
    @maps = Map.find(:all,:order => "id DESC",:limit => 20, :conditions => {:archived => false, :password => ''},:joins => :warpables, :group => "maps.id")
    render :layout => false, :template => "feeds/all.rss.builder"
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def license
    @maps = Map.find(:all,:order => "id DESC",:limit => 20, :conditions => {:archived => false, :password => '', :license => params[:id]},:joins => :warpables, :group => "maps.id")
    render :layout => false, :template => "feeds/license.rss.builder"
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def author
    @maps = Map.find_all_by_author(params[:id],:order => "id DESC", :conditions => {:archived => false, :password => ''},:joins => :warpables, :group => "maps.id")
    images = []
    @maps.each do |map|
      images = images + map.warpables
    end
    @feed = (@maps + images).sort_by(&:created_at)
    render :layout => false, :template => "feeds/author.rss.builder"
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def tag
    @tag = Tag.find_by_name params[:id]
    @maps = @tag.maps.paginate(:page => params[:page], :per_page => 24)
    render :layout => false, :template => "feeds/tag.rss.builder"
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

end
