# frozen_string_literal: true

class EventLog < ApplicationRecord
  include ActionView::Helpers::TextHelper

  belongs_to :user
  belongs_to :resourceable, polymorphic: true
end
