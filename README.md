# README

##	Steps to follow for integration of two factor authentication using Twilio with Rails

#### Getting credentials from Twilio
*	Sign-up for free trial account with twilio (https://www.twilio.com/try-twilio)
*	Open a console for creating new project/ for first time it is getting started (https://www.twilio.com/console/authy/applications)
*	Fill up the step by step procedure as phone no. followed by verification and then email, again vaild phone number through which messags will be sent and copy the curl code from the rigt side for reference
*	Once the getting started portion is over, we can move forward by going into the settings for the application where we can get all the credentials for the project (we need only PRODUCTION API KEY)

### Functions to perform before implementing code in Rails 
*	Mainly there are two function that needs to be perform
	1.	Get Country code and User Number and call related API amd according to the response perform move forword for next step
	2.	Verify code recived and call related API with the recived code and according to the response over API call, perform desired operation

### Credential setup in Rails project
*	Prepare a `.yml` file under config folder (ex. `/config/authy.yml`) file to store credentials as given in the admin panel of Integration Key, Secret Key and API hostname and add it as below
	```sh
	AUTHY_KEY: XXX
	```
*	Add `require 'yaml'` in `application.rb` located in `/config/application.rb`
*	Add associated Gem as `gem 'authy'` and run `bundle`
*	Load the Yaml file into the initializer folder by creating file as `authy.rb` located in `/config/initializers/authy.rb` and add following line of code
	```sh
	AUTHY = YAML.load_file(Rails.root.join('config/authy.yml'))
	Authy.api_key = AUTHY['AUTHY_KEY']
	Authy.api_uri = 'https://api.authy.com/'
	```

### Code integration in Rails project
*	Create appropriate routes as below,
	```sh
	resources :dashboards do
    	match :initial_step, on: :collection, via: [:get, :post]
    	match :verify_step, on: :collection, via: [:get, :post]
    	match :get_data_step, on: :collection, via: [:get, :post]
 	end
 	root to: 'dashboards#login_page'
 	```
 *	Create methods in `DashboardController` as
 	```sh
 	def initial_step
	    session[:phone_number] = params[:phone_number]
	    session[:country_code] = params[:country_code]
	    @response = Authy::PhoneVerification.start(
	      via: params[:method],
	      country_code: params[:country_code],
	      phone_number: params[:phone_number]
	    )
	    if @response.ok?
	      redirect_to get_data_step_dashboards_path
	    else
	      redirect_to root_path
	    end
	end
 	def login_page
 	end
  	def verify_step
	    @response = Authy::PhoneVerification.check(
	      verification_code: params[:code],
	      country_code: session[:country_code],
	      phone_number: session[:phone_number]
	    ) if params[:code].present?
	    if @response.ok?
	      session[:phone_number] = nil
	      session[:country_code] = nil
	      redirect_to dashboards_path
	    else
	      redirect_to get_data_step_dashboards_path
	    end
	  end
	  def get_data_step
	  end
 	```
 *	Create `login_page.html.erb` located at `/app/views/dashboards/login_page.html.erb` and add following code
 	```sh
 	<%= form_tag(initial_step_dashboards_path, method: :post) do -%>
	  <% if @response %>
	    <% @response.errors.each do |key, message| %>
	      <p><%= message %></p>
	    <% end %>
	  <% end %>
	  <div>
	    <%= label_tag "authy-countries", "Country code:" %>
	    <%= select_tag "authy-countries", nil, name: 'country_code', 'data-show-as': 'number' %>
	  </div>
	  <div>
	    <%= label_tag "phone_number", "Phone number:" %>
	    <%= telephone_field_tag "phone_number", nil, name: 'phone_number' %>
	  </div>
	  <div>
	    <p>Verification method</p>
	    <%= label_tag "method_sms", "SMS: " %>
	    <%= radio_button_tag "method", "sms" %>
	    <%= label_tag "method_call", "Call: " %>
	    <%= radio_button_tag "method", "call" %>
	  </div>
	  <%= button_tag "Verify" %>
	<% end %>
 	```
*	Create `get_data_step.html.erb` located at `/app/views/dashboards/get_data_step.html.erb` and add following code
	```sh
	<%= form_tag(verify_step_dashboards_path, method: :post) do -%>
	  <% if @response %>
	    <% @response.errors.each do |key, message| %>
	      <p><%= message %></p>
	    <% end %>
	  <% end %>
	  <div>
	    <%= label_tag "code", "Enter the code you were sent:" %>
	    <%= text_field_tag "code" %>
	  </div>
	  <%= button_tag "Verify" %>
	<% end -%>
	<%= link_to 'Back', dashboards_path %>
	```
*	And last part is to add appropriate stylesheet and javascript libraries into the layout `application.html.erb` located at
	```sh
	<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
	<%= stylesheet_link_tag    'https://cdnjs.cloudflare.com/ajax/libs/authy-form-helpers/2.3/form.authy.min.css', media: 'all', 'data-turbolinks-track': 'reload' %>
	<%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
	<%= javascript_include_tag 'https://cdnjs.cloudflare.com/ajax/libs/authy-form-helpers/2.3/form.authy.min.js', 'data-turbolinks-track': 'reload' %>
	```
*	Run the server with `rails s`
*	Cheers!


* For more detail over the topic (https://dev.to/twilio/verify-user-phone-numbers-in-ruby-on-rails-with-the-authy-phone-verification-api)