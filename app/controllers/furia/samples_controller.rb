# frozen_string_literal: true

module Furia
  class SamplesController < ApplicationController
    before_action :set_sample, only: %i[show destroy]

    def index
      @samples = Sample.order(created_at: :desc)
    end

    def show
    end

    def destroy
      @sample.destroy
      redirect_to samples_path
    end

    private

    def set_sample
      @sample = Sample.find(params[:id])
    end
  end
end
