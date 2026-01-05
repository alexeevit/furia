# frozen_string_literal: true

module Furia
  class Sample < ActiveRecord::Base
    serialize :data, JSON

    def root_group
      @root_group ||= Furia.entry_from_hash(data)
    end
  end
end
