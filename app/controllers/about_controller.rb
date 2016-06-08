class AboutController < ApplicationController

    def index
      respond_to do |format| #this is REST web-service support telling the server to respond (respond_to) in one of two formats depending on the request
        format.html
      end
    end

end
