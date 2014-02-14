class SitesController < ApplicationController
  def new
    @site = Site.new
  end

  def create
    url = params.require(:site)[:url]
    @site = Site.create(url: url)
    LinksWorker.perform_async(@site.id)
    respond_to do |f|
      f.html { redirect_to site_path(@site) }
      f.json { render :json => @site }
    end
  end

  def edit
    @site = Site.find(params[:id])
  end

  def show
    @site = Site.find(params[:id])

    @links = @site.links
    respond_to do |f|
      f.html
      f.json { render :json => @site.as_json(include: :links) }
    end
  end

  def linkfarm
  end

  rescue_from ActionController::ParameterMissing, :only => :create do |err|
    respond_to do |f|
      f.html do 
        redirect_to new_site_path
      end
      f.json {render :json  => {:error => err.message}, :status => 422}
    end
  end

  rescue_from ActionView::MissingTemplate, :only => [:new, :edit] do |exception|
    # use exception.path to extract the path information
    # This does not work for partials
    respond_to do |type|
      type.html { render :template => "errors/error_404", :layout => 'application', :status => 404 }
      type.json  { render :json  => {:error => "404, not found"}, :status => 404 }
    end
    true  # so we can do "render_404 and return"
  end

end

  # rescue_from ActionController::ParameterMissing, :handle_create_param_missing :only => :create
  #
  # def handle_create_param_missing
  #    respond_to do |f|
  #     f.html do 
  #       redirect_to new_site_path
  #     end
  #     f.json {render :json  => {:error => err.message}, :status => 422}
  #   end
  # #
