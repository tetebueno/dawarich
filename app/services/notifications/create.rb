# frozen_string_literal: true

class Notifications::Create
  attr_reader :user, :kind, :title, :content

  def initialize(user:, kind:, title:, content:)
    @user     = user
    @kind     = kind
    @title    = title
    @content  = content
  end

  def call
    Notification.create!(user:, kind:, title:, content:)
  end
end
