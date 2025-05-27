
module Flocks
    class FlockPolicy
        def innitialize(account, flock)
            @account = account
            @flock = flock
        end

        def can_change_destination_url?
            account_is_creator?
        end

        def can_leave?
            account_is_visitor?
        end

        def can_delete?
            account_is_creator?
        end

        def summary
            {
                can_change_destination_url: can_change_destination_url?,
                can_leave: can_leave?,
                can_delete: can_delete?
            }
        end

        private

        def account_is_creator?
            @account.id == @flock.creator_id
        end

        def account_is_visitor?
            @account.id != @flock.creator_id
        end

    end
end
