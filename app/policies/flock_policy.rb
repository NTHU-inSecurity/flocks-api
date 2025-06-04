# frozen_string_literal: true

module Flocks
  class FlockPolicy
    def initialize(account, flock, auth_scope = nil)
      @account = account
      @flock = flock
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_creator? || account_is_visitor?)
    end

    def can_change_destination_url?
      can_write? && account_is_creator?
    end

    def can_leave?
      account_is_visitor?
    end

    def can_delete?
      account_is_creator?
    end

    def summary
      {
        can_view: can_view?,
        can_change_destination_url: can_change_destination_url?,
        can_leave: can_leave?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('flocks') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('flocks') : false
    end

    def account_is_creator?
      @account.id == @flock.creator_id
    end

    def account_is_visitor?
      @flock.birds.any? { |bird| bird.account_id == @account.id } && @account.id != @flock.creator_id
    end
  end
end
