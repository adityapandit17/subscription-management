class AddStripeFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :stripe_subscription_id, :string
    add_column :subscriptions, :current_period_start, :datetime
    add_column :subscriptions, :current_period_end, :datetime

    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
