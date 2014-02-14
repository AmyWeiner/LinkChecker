require 'spec_helper'

describe "Sites" do
	describe "POST /sites" do 
		let(:data){ {site: {url: "example.com"}} }
		it 'adds and redirects after a format html post' do
			post '/sites', data
			response.code.should == "302"
			site = Site.where(:url => data[:site][:url]).first
			site.should_not be_nil
			response.should redirect_to site
		end

		it 'redirects when getting wrong parameters with HTML' do
			post '/sites', {:wrong => "stuff"}
			response.should_not be_success
			response.should redirect_to new_site_path
		end

		# this simulates:
		# result = Typhoeus.post("SERVER/sites.json", params: {"site" => {"url" => "example.com"}})
		it 'adds after a format json post' do
			post '/sites.json', data
			response.status.should == 200
			site = Site.where(:url => data[:site][:url]).first
			site.should_not be_nil
			JSON.parse(response.body)["id"].should == site.id
		end

		it 'is a 422 with wrong parameters' do
			post '/sites.json', {:stuff => "wrong"}.to_json, {"CONTENT_TYPE" => "application/json"}
			response.code.should == "422"
			result = JSON.parse(response.body)
			result["error"].should == "param not found: site"
		end
	end

	describe "GET /sites/:id" do
		before do
			@site = Site.create!(:url => "no-links-here.com")
		end
		it 'gets an html page for an html GET' do
			get "/sites/#{@site.id}"
			response.should be_success
			response.body.should include(@site.url)
		end
		it 'gets JSON for a json GET' do
			get "/sites/#{@site.id}.json"
			response.should be_success
			JSON.parse(response.body).should include "url" => @site.url
		end
		it 'includes the links for a json GET' do
			@site.links.create!(:url => "linked-to.com", :http_response => 200 )
			get "/sites/#{@site.id}.json"
			response.should be_success
			result = JSON.parse(response.body)
			result["links"].should_not == nil
			result["links"].first.should include({"url" => "linked-to.com", "http_response" => 200})
		end

	end

	describe "GET /sites/:id/edit" do
		before do
			@site = Site.create!(:url => "no-links-here.com")
		end
		it 'is successful with HTML' do
			get "/sites/#{@site.id}/edit"
			response.should be_success
		end

		it 'is a 404 with JSON' do
			get "/sites/#{@site.id}/edit.json"
			response.status.should == 404
		end
	end

	describe "GET /sites/new" do
		it 'is successful with HTML' do
			get '/sites/new'
			response.status.should == 200
		end

		it 'is a 404 with JSON' do
			get "/sites/new.json"
			response.status.should == 404
		end
	end

	describe "GET /linkfarm/" do
		it 'gets the links with HTML'
		it 'gets the links with JSON'
	end

	describe "DELETE /sites/:id" do
		before do
			@site = Site.create!(:url => "no-links-here.com")
		end
		it 'succeeds and redirects with HTML' do
			delete "/sites/#{@site.id}"
      response.code.should == "302"
		end

		it 'succeeds and does not redirect with JSON' do
			delete "/sites/#{@site.id}.json"
      deleted = Site.where(id: @site.id).exists?
      deleted.should == false
      response.code.should == "204"
		end
	end
end